;; FundFlow - Transparent Startup Fundraising Platform

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-campaign-not-found (err u102))
(define-constant err-campaign-ended (err u103))
(define-constant err-insufficient-funds (err u104))
(define-constant err-invalid-parameter (err u105))
(define-constant err-milestone-not-found (err u106))
(define-constant err-already-voted (err u107))
(define-constant err-voting-period-ended (err u108))
(define-constant err-milestone-not-completed (err u109))

;; Data variables
(define-data-var total-campaigns uint u0)
(define-data-var platform-fee-percentage uint u250) ;; 2.5%
(define-data-var total-platform-fees uint u0)
(define-data-var paused bool false)

;; Campaign data structure
(define-map campaigns
    uint
    {
        founder: principal,
        title: (string-utf8 64),
        description: (string-utf8 256),
        funding-goal: uint,
        total-raised: uint,
        deadline: uint,
        active: bool,
        completed: bool,
        milestone-count: uint,
    }
)

;; Investment tracking
(define-map campaign-investments
    {
        campaign-id: uint,
        investor: principal,
    }
    {
        amount: uint,
        timestamp: uint,
        equity-tokens: uint,
    }
)

;; Investor portfolio
(define-map investor-portfolios
    principal
    {
        total-invested: uint,
        active-campaigns: uint,
        total-returns: uint,
    }
)

;; Campaign statistics
(define-map campaign-stats
    uint
    {
        total-investors: uint,
        average-investment: uint,
        last-update: uint,
    }
)

;; Read-only functions
(define-read-only (get-campaign-details (campaign-id uint))
    (map-get? campaigns campaign-id)
)

(define-read-only (get-investment-details
        (campaign-id uint)
        (investor principal)
    )
    (map-get? campaign-investments {
        campaign-id: campaign-id,
        investor: investor,
    })
)

(define-read-only (get-investor-portfolio (investor principal))
    (map-get? investor-portfolios investor)
)

(define-read-only (get-campaign-stats (campaign-id uint))
    (map-get? campaign-stats campaign-id)
)

(define-read-only (get-total-campaigns)
    (var-get total-campaigns)
)

(define-read-only (get-platform-fee-percentage)
    (var-get platform-fee-percentage)
)

(define-read-only (is-contract-paused)
    (var-get paused)
)

;; Private functions
(define-private (calculate-platform-fee (amount uint))
    (/ (* amount (var-get platform-fee-percentage)) u10000)
)

(define-private (calculate-equity-tokens
        (investment uint)
        (funding-goal uint)
    )
    ;; Simple equity calculation: (investment / funding-goal) * 10000 tokens
    (/ (* investment u10000) funding-goal)
)

;; Administrative functions
(define-public (set-platform-fee (new-fee uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (<= new-fee u1000) err-invalid-parameter) ;; Max 10%
        (var-set platform-fee-percentage new-fee)
        (ok true)
    )
)

(define-public (toggle-pause)
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set paused (not (var-get paused)))
        (ok true)
    )
)

(define-public (withdraw-platform-fees)
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (let ((fees (var-get total-platform-fees)))
            (var-set total-platform-fees u0)
            (stx-transfer? fees tx-sender contract-owner)
        )
    )
)
