// 自定义启动脚本：取代 Flutter 默认引导（默认引导会注册并随即注销 flutter_service_worker.js）
{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine({
      // 不传 serviceWorkerSettings，避免注册 Flutter 自带的自注销 SW；
      // 离线缓存由仓库内的 web/sw.js 接管。
    });
    await appRunner.runApp();
  }
});
