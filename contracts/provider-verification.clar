;; Provider Verification Contract
;; This contract validates healthcare entities

(define-data-var admin principal tx-sender)

;; Map to store verified providers
(define-map verified-providers principal
  {
    name: (string-utf8 100),
    license-number: (string-utf8 50),
    specialty: (string-utf8 50),
    verified: bool
  }
)

;; Function to register a new provider (only admin can call)
(define-public (register-provider (provider principal) (name (string-utf8 100)) (license-number (string-utf8 50)) (specialty (string-utf8 50)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-none (map-get? verified-providers provider)) (err u100))
    (ok (map-set verified-providers provider {
      name: name,
      license-number: license-number,
      specialty: specialty,
      verified: true
    }))
  )
)

;; Function to check if a provider is verified
(define-read-only (is-provider-verified (provider principal))
  (match (map-get? verified-providers provider)
    provider-data (ok (get verified provider-data))
    (ok false)
  )
)

;; Function to revoke provider verification
(define-public (revoke-provider (provider principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-some (map-get? verified-providers provider)) (err u404))
    (ok (map-delete verified-providers provider))
  )
)

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (var-set admin new-admin))
  )
)
