# AwemeLike

项目是仿照抖音的特效相机，基本功能是使用相机拍摄短视频，然后在视频的基础上添加一些视频特效。

#### 已实现功能

- 磨皮、美白
- 瘦脸大眼、唇彩、腮红等脸部处理
- 2D动态贴纸
- 分屏
- 转场
- 常用滤镜，比如抖动、摇摆、毛刺等

#### 待完成
- 多段视频合并
- 变速播放和倒放
- 3D贴纸

#### 存在的问题

由于项目播放器的解码部分是由`AVAssetReader`完成的，而`AVAssetReader`并不适合用来做这种可以重置播放进度的实时视频播放，因为对于`AVAssetReader`来说，重置播放进度都是一个非常耗时的操作，而且视频文件越大耗时越多，当耗时多了就会导致声音出现噪音。

所以编辑的视频最好是在1分钟以内，这样播放时可能偶尔才会有噪音出现，不仔细听其实是很难发现的。
这个问题好像是很难避免的，一种更好的方式是，使用FFmpeg解封装，然后使用VideoToolBox解码视频帧，后面有时间会切换到这种方式。

#### 关于face++的授权

使用前需要替换Face++的key和secret，就是下面的两个宏，在项目中，它的文件路径是`Face++/MGNetAccount.h`
```
// 访问 https://www.faceplusplus.com.cn， 登录后在控制台生成对应的 key 和 secret 填写到下面的字符串中


#define MG_LICENSE_KEY      @"" // api_key
#define MG_LICENSE_SECRET    @"" // api_secret


#endif /* MGNetAccount_example_h */
```

然后调用授权方法，授权成功之后才能使用face++的人脸检测
```
[[FaceDetector shareInstance] auth];
```


#### 效果展示

**美颜**

![](https://github.com/ZZZZou/AwemeLike/blob/master/resource/1.gif)

**设置特效**

![](https://github.com/ZZZZou/AwemeLike/blob/master/resource/2.gif)

**生成的视频文件**

![](https://github.com/ZZZZou/AwemeLike/blob/master/resource/3.gif)

#### 相关文章

[视频播放器的实现](https://www.jianshu.com/p/1b72ef66ccde)

[大眼瘦脸的实现](https://www.jianshu.com/p/1cd3ed0e29ea)

