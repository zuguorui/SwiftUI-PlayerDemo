class PlayerContainerView: UIView {
    let playerLayer = AVPlayerLayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}