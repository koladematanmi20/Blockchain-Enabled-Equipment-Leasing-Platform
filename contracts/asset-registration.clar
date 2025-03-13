;; Asset Registration Contract
;; Records details of available equipment for lease

(define-data-var asset-counter uint u0)

(define-map assets
  { id: uint }
  {
    name: (string-ascii 64),
    category: (string-ascii 32),
    model: (string-ascii 64),
    manufacturer: (string-ascii 64),
    serial-number: (string-ascii 64),
    owner: principal,
    available: bool,
    daily-rate: uint,
    deposit-amount: uint
  }
)

(define-map asset-specifications
  { asset-id: uint, spec-id: uint }
  {
    key: (string-ascii 32),
    value: (string-ascii 64)
  }
)

(define-map asset-documents
  { asset-id: uint, doc-id: uint }
  {
    name: (string-ascii 64),
    doc-type: (string-ascii 32),
    url: (string-ascii 256),
    timestamp: uint
  }
)

(define-map asset-images
  { asset-id: uint, image-id: uint }
  {
    description: (string-ascii 64),
    url: (string-ascii 256)
  }
)

;; Register a new asset
(define-public (register-asset
              (name (string-ascii 64))
              (category (string-ascii 32))
              (model (string-ascii 64))
              (manufacturer (string-ascii 64))
              (serial-number (string-ascii 64))
              (daily-rate uint)
              (deposit-amount uint))
  (let ((new-id (+ (var-get asset-counter) u1)))
    ;; Update counter
    (var-set asset-counter new-id)

    ;; Store asset data
    (map-set assets
      { id: new-id }
      {
        name: name,
        category: category,
        model: model,
        manufacturer: manufacturer,
        serial-number: serial-number,
        owner: tx-sender,
        available: true,
        daily-rate: daily-rate,
        deposit-amount: deposit-amount
      }
    )

    (ok new-id)
  )
)

;; Add a specification to an asset
(define-public (add-specification
              (asset-id uint)
              (spec-id uint)
              (key (string-ascii 32))
              (value (string-ascii 64)))
  (let ((asset (map-get? assets { id: asset-id })))
    ;; Asset must exist
    (asserts! (is-some asset) (err u1))

    ;; Only owner can add specifications
    (asserts! (is-eq tx-sender (get owner (unwrap-panic asset))) (err u2))

    ;; Store specification
    (map-set asset-specifications
      { asset-id: asset-id, spec-id: spec-id }
      {
        key: key,
        value: value
      }
    )

    (ok true)
  )
)

;; Add a document to an asset
(define-public (add-document
              (asset-id uint)
              (doc-id uint)
              (name (string-ascii 64))
              (doc-type (string-ascii 32))
              (url (string-ascii 256)))
  (let ((asset (map-get? assets { id: asset-id })))
    ;; Asset must exist
    (asserts! (is-some asset) (err u1))

    ;; Only owner can add documents
    (asserts! (is-eq tx-sender (get owner (unwrap-panic asset))) (err u2))

    ;; Store document
    (map-set asset-documents
      { asset-id: asset-id, doc-id: doc-id }
      {
        name: name,
        doc-type: doc-type,
        url: url,
        timestamp: block-height
      }
    )

    (ok true)
  )
)

;; Add an image to an asset
(define-public (add-image
              (asset-id uint)
              (image-id uint)
              (description (string-ascii 64))
              (url (string-ascii 256)))
  (let ((asset (map-get? assets { id: asset-id })))
    ;; Asset must exist
    (asserts! (is-some asset) (err u1))

    ;; Only owner can add images
    (asserts! (is-eq tx-sender (get owner (unwrap-panic asset))) (err u2))

    ;; Store image
    (map-set asset-images
      { asset-id: asset-id, image-id: image-id }
      {
        description: description,
        url: url
      }
    )

    (ok true)
  )
)

;; Update asset availability
(define-public (update-availability
              (asset-id uint)
              (available bool))
  (let ((asset (map-get? assets { id: asset-id })))
    ;; Asset must exist
    (asserts! (is-some asset) (err u1))

    ;; Only owner can update availability
    (asserts! (is-eq tx-sender (get owner (unwrap-panic asset))) (err u2))

    ;; Update asset
    (map-set assets
      { id: asset-id }
      (merge (unwrap-panic asset) { available: available })
    )

    (ok true)
  )
)

;; Update asset rates
(define-public (update-rates
              (asset-id uint)
              (daily-rate uint)
              (deposit-amount uint))
  (let ((asset (map-get? assets { id: asset-id })))
    ;; Asset must exist
    (asserts! (is-some asset) (err u1))

    ;; Only owner can update rates
    (asserts! (is-eq tx-sender (get owner (unwrap-panic asset))) (err u2))

    ;; Update asset
    (map-set assets
      { id: asset-id }
      (merge (unwrap-panic asset) {
        daily-rate: daily-rate,
        deposit-amount: deposit-amount
      })
    )

    (ok true)
  )
)

;; Get asset details
(define-read-only (get-asset (asset-id uint))
  (map-get? assets { id: asset-id })
)

;; Get asset specification
(define-read-only (get-specification (asset-id uint) (spec-id uint))
  (map-get? asset-specifications { asset-id: asset-id, spec-id: spec-id })
)

;; Get asset document
(define-read-only (get-document (asset-id uint) (doc-id uint))
  (map-get? asset-documents { asset-id: asset-id, doc-id: doc-id })
)

;; Get asset image
(define-read-only (get-image (asset-id uint) (image-id uint))
  (map-get? asset-images { asset-id: asset-id, image-id: image-id })
)

;; Check if asset is available
(define-read-only (is-available (asset-id uint))
  (let ((asset (map-get? assets { id: asset-id })))
    (if (is-some asset)
      (get available (unwrap-panic asset))
      false
    )
  )
)
