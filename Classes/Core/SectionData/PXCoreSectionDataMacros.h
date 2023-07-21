//
//  PXCoreSectionDataMacros.h
//  Pods
//
//  Created by 胡伟伟 on 2023/7/13.
//

#ifndef PXCoreSectionDataMacros_h
#define PXCoreSectionDataMacros_h

#define PX_CORE_SECTION_NAME "__bf_core_config"

#define PX_CORE_CONCAT2(A, B) A ## B

#define PX_CORE_CONCAT(A, B) PX_CORE_CONCAT2(A, B)

#define PX_CORE_SECTION(name) __attribute((used, section("__DATA,"#name" ")))

#define PX_CORE_CONFIG_SECTION PX_CORE_SECTION(__bf_core_config)

#define PX_CORE_UNIQUE_ID(key) PX_CORE_CONCAT(key, PX_CORE_CONCAT(__LINE__, __COUNTER__))


#define PX_CORE_REGISTER(_protocol, _className) \
char * PX_CORE_UNIQUE_ID(_className) PX_CORE_CONFIG_SECTION = (char *)""#_protocol"#"#_className""; \

#endif /* PXCoreSectionDataMacros_h */
