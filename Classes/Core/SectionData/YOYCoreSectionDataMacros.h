//
//  YOYCoreSectionDataMacros.h
//  Pods
//
//  Created by 胡伟伟 on 2023/8/11.
//

#ifndef YOYCoreSectionDataMacros_h
#define YOYCoreSectionDataMacros_h


#define YOY_CORE_SECTION_NAME "__bf_core_config"

#define YOY_CORE_CONCAT2(A, B) A ## B

#define YOY_CORE_CONCAT(A, B) YOY_CORE_CONCAT2(A, B)

#define YOY_CORE_SECTION(name) __attribute((used, section("__DATA,"#name" ")))

#define YOY_CORE_CONFIG_SECTION YOY_CORE_SECTION(__bf_core_config)

#define YOY_CORE_UNIQUE_ID(key) YOY_CORE_CONCAT(key, YOY_CORE_CONCAT(__LINE__, __COUNTER__))


#define YOY_CORE_REGISTER(_protocol, _className) \
char * YOY_CORE_UNIQUE_ID(_className) YOY_CORE_CONFIG_SECTION = (char *)""#_protocol"#"#_className""; \

#endif /* YOYCoreSectionDataMacros_h */
