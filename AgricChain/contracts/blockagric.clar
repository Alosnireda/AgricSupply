// Supply Chain Tracking Smart Contract for Agricultural Produce

(define-data-var product-counter uint 0)

(define-map products 
  { product-id: uint } 
  { producer: principal, 
    product-name: (string-ascii 100), 
    description: (string-ascii 250), 
    location: (string-ascii 100), 
    status: (string-ascii 50),
    timestamp: uint 
  })

(define-map product-history 
  { product-id: uint, history-id: uint } 
  { location: (string-ascii 100), 
    status: (string-ascii 50), 
    timestamp: uint 
  })

(define-event product-registered (id uint producer principal name (string-ascii 100) description (string-ascii 250) location (string-ascii 100)))

(define-event product-updated (id uint location (string-ascii 100) status (string-ascii 50)))

(define-public (register-product (name (string-ascii 100)) (description (string-ascii 250)) (location (string-ascii 100)))
  (let (
    (new-id (+ (var-get product-counter) u1))
    (timestamp (block-height))
    (producer tx-sender)
  )
    (begin
      ;; Register new product
      (map-insert products { product-id: new-id } { 
        producer: producer, 
        product-name: name, 
        description: description, 
        location: location, 
        status: "Registered", 
        timestamp: timestamp 
      })
      ;; Emit registration event
      (print (product-registered { id: new-id, producer: producer, name: name, description: description, location: location }))
      ;; Update product counter
      (var-set product-counter new-id)
      (ok new-id)
    )
  )
)

(define-public (update-product (product-id uint) (location (string-ascii 100)) (status (string-ascii 50)))
  (let (
    (product (map-get? products { product-id: product-id }))
    (timestamp (block-height))
  )
    (match product
      (some product-data
        (let (
          (producer (get producer product-data))
        )
          (if (is-eq tx-sender producer)
            (begin
              ;; Update product information
              (map-set products { product-id: product-id } { 
                producer: producer, 
                product-name: (get product-name product-data), 
                description: (get description product-data), 
                location: location, 
                status: status, 
                timestamp: timestamp 
              })
              ;; Log history of product update
              (map-insert product-history { product-id: product-id, history-id: timestamp } { 
                location: location, 
                status: status, 
                timestamp: timestamp 
              })
              ;; Emit update event
              (print (product-updated { id: product-id, location: location, status: status }))
              (ok true)
            )
            (err "Unauthorized: Only the producer can update the product information.")
          )
        )
        (err "Product not found.")
    ))
)

(define-read-only (get-product-details (product-id uint))
  (match (map-get? products { product-id: product-id })
    (some product-data
      (ok product-data)
    )
    (err "Product not found.")
  )
)

(define-read-only (get-product-history (product-id uint))
  (ok (map-get-entries product-history { product-id: product-id }))
)
