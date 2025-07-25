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
