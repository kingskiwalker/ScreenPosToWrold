# 还原方法
从屏幕坐标中还原世界坐标 目前我知道的有两种方法，一种是通过NDC坐标重构世界坐标 一种是通过摄像机算出4个近面点的方向,通过深度图还原世界坐标。
### 选择考虑
由于通过4近面点方向的方法只需要在顶点中进行插值，在Fragmen比NDC转换方法少了矩阵运算，性能方面更优
### 实现

1. 在c#脚本中求出摄像机近平面4个顶点,然后存储在4x4矩阵中传入shader
```

        var aspect = camera.aspect;
        var far = camera.farClipPlane;
        var right = camera.transform.right;
        var up = camera.transform.up;
        var forward = camera.transform.forward;
        var halfFovTan = Mathf.Tan (camera.fieldOfView * 0.5f * Mathf.Deg2Rad);
        
        var rightVec = right * far * halfFovTan * aspect;
        var upVec = up * far * halfFovTan;
        var forwardVec = forward * far;
        var topLeft = forwardVec - rightVec + upVec;
        var topRight = forwardVec + rightVec + upVec;
        var bottomleft = forwardVec - rightVec - upVec;
        var bottomRight = forwardVec + rightVec - upVec;
        
        var mar = Matrix4x4.identity;
        mar.SetRow (0, topLeft);
        mar.SetRow (1, topRight);
        mar.SetRow (2, bottomleft);
        mar.SetRow (3, bottomRight);


```
2. 在shader中进行插值， 在这一步 由于我用的是PostProcessing 4个顶点间的插值并未是0~1而是-1~1 所以手动进行双线性插值。
```
   o.ray  = lerp(lerp(_CamRay[2],_CamRay[0],uv.y),lerp(_CamRay[3],_CamRay[1],uv.y),uv.x);
```
3. 接着就是在frag中 根据从顶点中插值得到的向量，也就是从摄像机中到当前像素的方向向量。通过这个向量加上相机的位置 再乘上深度信息，就得出当前像素对应的三维世界坐标
```

        float depth = SAMPLE_TEXTURE2D(_CameraDepthTexture,sampler_CameraDepthTexture,i .texcoord);
        depth = Linear01Depth(depth);
        i.ray.xyz = i.ray.xyz*depth+_WorldSpaceCameraPos


```
至此 已经完成从屏幕空间到三维坐标系的转换了



>参考 
>[Unity Shader 深度值重建世界坐标](https://www.jianshu.com/p/3f3a3911a824)
>[坐标转换到世界坐标要点](https://www.cnblogs.com/sword-magical-blog/p/10483459.html) 
>git地址