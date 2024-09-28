;; Supply Chain Tracking Smart Contract for Agricultural Produce

;; Constants for error codes
(define-constant ERR-INVALID-STRING-LENGTH u1)
(define-constant ERR-PRODUCT-NOT-FOUND u2)
(define-constant ERR-UNAUTHORIZED u3)
(define-constant ERR-INVALID-INPUT u4)

;; Initialize product counter
(define-data-var product-counter uint u0)

;; Map to store product details
(define-map products 
  { product-id: uint } 
  { producer: principal, 
    product-name: (string-ascii 100), 
    description: (string-ascii 250), 
    location: (string-ascii 100), 
    status: (string-ascii 50),
    timestamp: uint 
  })

;; Map to store history of product updates
(define-map product-history 
  { product-id: uint, history-id: uint } 
  { location: (string-ascii 100), 
    status: (string-ascii 50), 
    timestamp: uint 
  })

;; Map to store the count of history updates for each product
(define-map product-history-count
  { product-id: uint }
  { update-count: uint })

;; Function to validate string length
(define-private (validate-string-length (input (string-ascii 250)) (max-length uint))
  (if (<= (len input) max-length)
    (ok input)
    (err ERR-INVALID-STRING-LENGTH)
  )
)

;; Function to check if a product exists and the caller is the owner
(define-private (is-valid-product-and-owner (product-id uint))
  (match (map-get? products { product-id: product-id })
    product (is-eq (get producer product) tx-sender)
    false
  )
)

;; Function to register a new product
(define-public (register-product (name (string-ascii 100)) (description (string-ascii 250)) (location (string-ascii 100)))
  (let (
    (new-id (+ (var-get product-counter) u1))
    (timestamp block-height)
    (producer tx-sender)
  )
    (begin
      ;; Validate input lengths
      (asserts! (is-ok (validate-string-length name u100)) (err ERR-INVALID-STRING-LENGTH))
      (asserts! (is-ok (validate-string-length description u250)) (err ERR-INVALID-STRING-LENGTH))
      (asserts! (is-ok (validate-string-length location u100)) (err ERR-INVALID-STRING-LENGTH))
      
      ;; Register new product
      (map-insert products { product-id: new-id } { 
        producer: producer, 
        product-name: name, 
        description: description, 
        location: location, 
        status: "Registered", 
        timestamp: timestamp 
      })
      ;; Initialize product history count
      (map-insert product-history-count { product-id: new-id } { update-count: u0 })
      ;; Emit registration event (log data to chain)
      (print { 
        event: "product-registered", 
        id: new-id, 
        producer: producer, 
        name: name, 
        description: description, 
        location: location 
      })
      ;; Update product counter
      (var-set product-counter new-id)
      (ok new-id)
    )
  )
)

;; Function to update an existing product
(define-public (update-product (product-id uint) (location (string-ascii 100)) (status (string-ascii 50)))
  (let (
    (timestamp block-height)
  )
    (asserts! (is-valid-product-and-owner product-id) (err ERR-UNAUTHORIZED))
    ;; Validate input lengths
    (asserts! (is-ok (validate-string-length location u100)) (err ERR-INVALID-STRING-LENGTH))
    (asserts! (is-ok (validate-string-length status u50)) (err ERR-INVALID-STRING-LENGTH))
    
    (match (map-get? products { product-id: product-id })
      product
        (let (
          (current-count (default-to u0 (get update-count (map-get? product-history-count { product-id: product-id }))))
          (new-count (+ current-count u1))
        )
          (begin
            ;; Update product information
            (map-set products { product-id: product-id } { 
              producer: (get producer product), 
              product-name: (get product-name product), 
              description: (get description product), 
              location: location, 
              status: status, 
              timestamp: timestamp 
            })
            ;; Log history of product update
            (map-insert product-history { product-id: product-id, history-id: new-count } { 
              location: location, 
              status: status, 
              timestamp: timestamp 
            })
            ;; Update product history count
            (map-set product-history-count { product-id: product-id } { update-count: new-count })
            ;; Emit update event (log data to chain)
            (print { 
              event: "product-updated", 
              id: product-id, 
              location: location, 
              status: status 
            })
            (ok true)
          )
        )
      (err ERR-PRODUCT-NOT-FOUND)
    )
  )
)

;; Function to get product details
(define-read-only (get-product-details (product-id uint))
  (match (map-get? products { product-id: product-id })
    product-data (ok product-data)
    (err ERR-PRODUCT-NOT-FOUND)
  )
)

;; Function to get product update history by index
(define-read-only (get-product-history-entry (product-id uint) (history-id uint))
  (match (map-get? product-history { product-id: product-id, history-id: history-id })
    history-entry (ok history-entry)
    (err ERR-PRODUCT-NOT-FOUND)
  )
)

;; Function to get the number of history updates for a product
(define-read-only (get-product-history-count (product-id uint))
  (match (map-get? product-history-count { product-id: product-id })
    count-data (ok (get update-count count-data))
    (err ERR-PRODUCT-NOT-FOUND)
  )
)