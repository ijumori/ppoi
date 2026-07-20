import CoreGraphics

/// レイアウト間隔の共通スケール。
/// 既存コードで実際に使われている値（2/4/6/8/12/16/24/32/48）に 1:1 で対応し、
/// 置換してもピクセルが変わらないようにしている。
enum Spacing {
    /// 2pt
    static let xxxs: CGFloat = 2
    /// 4pt
    static let xxs: CGFloat = 4
    /// 6pt
    static let xs: CGFloat = 6
    /// 8pt
    static let s: CGFloat = 8
    /// 12pt
    static let m: CGFloat = 12
    /// 16pt
    static let l: CGFloat = 16
    /// 24pt
    static let xl: CGFloat = 24
    /// 32pt
    static let xxl: CGFloat = 32
    /// 48pt
    static let xxxl: CGFloat = 48
}
