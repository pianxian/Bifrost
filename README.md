# Bifrost
iOS组件化管理框架
/// 通过类名获取对象
#define GetCore(className) ((className *)[YOYCoresService registerCore:[className class]])

/// 需要手动注册协议，调用时候去注册表里面匹配绑定的core
#define GetCoreI(InterfaceName) ((id<InterfaceName>)[YOYCoresService registerCoreI:@protocol(InterfaceName)])

/**
 * YOYGetCoreI、YOYGetClassI 自注册方案，但是这样会影响运行时性能
 * 通过协议名称去匹配core，如果协议本身不符合规则，需要提前注册兜底逻辑
 * 正常逻辑添加头文件：#import <YOYCoreSectionDataMacros.h>
 * 然后使用 PX_CORE_REGISTER 绑定协议和 core
 */

/// 通过协议获取对象-自注册
#define YOYGetCoreI(InterfaceName) ((id<InterfaceName>)[YOYCoresService registerMappedCoreI:@protocol(InterfaceName)])

/// 通过协议映射类方法-自注册，只需要调用 Class 对应的方法时可以使用该宏定义
#define YOYGetClassI(InterfaceName) ((Class<InterfaceName>)[YOYCoresService registerMappedClassI:@protocol(InterfaceName)])

/// 如果需要调用 Class 对应的 alloc 方法，则需要通过此方法来获取对应的 Class ，不包含 InterfaceName 定义，否则编译器会报错，提示找不到对应的 alloc 方法
/// 请注意，这样获取的对象，并不是单例，生命周期请自行管理
/// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjectiveC/Chapters/ocProtocols.html
/// Protocols can’t be used to type class objects. Only instances can be statically typed to a protocol, just as only instances can be statically typed to a class. (However, at runtime, both classes and instances respond to a conformsToProtocol: message.)
#define YOYGetClass(InterfaceName) ((Class)[YOYCoresService registerMappedClassI:@protocol(InterfaceName)])

#define YOYGetCore(InterfaceName) ((id<InterfaceName>)[YOYCoresService registerMappedCore:@protocol(InterfaceName)])

example  
   [YOYGetCoreI(IPXExampleCore) helloWorld];

  //regist URIRouter
  PXURIRegisterManager.inited = YES;
  [PXURIRegisterManager registerURINavisAuto];
  
  cocopods 导入 
```
pod 'Bifrost'
 ```
