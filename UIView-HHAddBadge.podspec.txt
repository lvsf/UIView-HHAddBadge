Pod::Spec.new do |s|
    s.name         = 'UIView+HHAddBadge'
    s.version      = '0.0.2'
    s.summary      = 'add badge'
    s.homepage     = 'https://github.com/lvsf/UIView-HHAddBadge'
    s.license      = 'MIT'
    s.authors      = {'lvsf' => 'lvsf1992@163.com'}
    s.platform     = :ios, '7.0'
    s.source       = {:git => 'https://github.com/lvsf/UIView-HHAddBadge.git', :tag => s.version}
    s.source_files = 'UIView-HHAddBadge/Class/*.{h,m}'
    s.requires_arc = true
end
