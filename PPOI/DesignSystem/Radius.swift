import CoreGraphics

/// 角丸の共通スケール。
/// 既存コードで実際に使われている cornerRadius 値（6/8/10/12/16）に 1:1 で対応する。
enum Radius {
    /// 6pt
    static let s: CGFloat = 6
    /// 8pt
    static let m: CGFloat = 8
    /// 10pt
    static let l: CGFloat = 10
    /// 12pt
    static let xl: CGFloat = 12
    /// 16pt
    static let xxl: CGFloat = 16
}
