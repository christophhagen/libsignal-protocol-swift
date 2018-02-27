Pod::Spec.new do |spec|
    spec.name = 'libsignal-protocol-swift'
    spec.summary = 'A Swift wrapper framework for libsignal-protocol-c'
    spec.license = 'GPLv3'

    spec.version = '0.2.2'
    spec.source = {
        :git => 'https://github.com/christophhagen/libsignal-protocol-swift.git',
        :tag => spec.version
    }
    spec.swift_version = '4.0'
    spec.module_name  = 'SignalProtocol'

    spec.authors = { 'Christoph Hagen' => 'christoph@spacemasters.eu' } 
    spec.homepage = 'https://github.com/christophhagen/libsignal-protocol-swift'

    spec.ios.deployment_target = '9.0'
    spec.osx.deployment_target = '10.9'
    spec.tvos.deployment_target = '9.0'
    spec.watchos.deployment_target = '4.0'

    spec.source_files = 'libsignal-protocol-swift/**/*.{swift,c,h}'
    spec.public_header_files = ''
    spec.private_header_files = 'libsignal-protocol-swift/**/*.h'

    spec.pod_target_xcconfig = { 
    	'SWIFT_INCLUDE_PATHS' => '${BUILT_PRODUCTS_DIR}/SignalModuleMap, ${BUILT_PRODUCTS_DIR}/CommonCryptoModuleMap'
    }
    spec.resources = '$(BUILT_PRODUCTS_DIR)/**/*.modulemap'
    spec.preserve_paths = '$(BUILT_PRODUCTS_DIR)/**/*.modulemap'
    
end
