class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
		return true if RUBYMOTION_ENV == 'test'

    @_view_controller = ViewController.alloc.init #.new
    @_view_controller.title = 'basic-physbod-demo'
    @_view_controller.view.backgroundColor = UIColor.whiteColor

    UIApplication.sharedApplication.setIdleTimerDisabled(true)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = @_view_controller
    @window.makeKeyAndVisible

    true
  end
end
