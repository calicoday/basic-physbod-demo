class ViewController < UIViewController
  def viewDidLoad
    super

    self.view = sk_view 
    @tally_scene = TallyScene.sceneWithSize(sk_view.frame.size)		    		
    @edge_scene = EdgeRunnerScene.sceneWithSize(sk_view.frame.size)		    		
    @drag_scene = DragWithPhysicsScene.sceneWithSize(sk_view.frame.size)		    		
    sk_view.presentScene(@tally_scene)
  end
  
  def sk_view
    @_sk_view ||= SKView.alloc.initWithFrame(CGRectMake(0, 0, 
      UIScreen.mainScreen.bounds.size.width, 
      UIScreen.mainScreen.bounds.size.height))
    @_sk_view.ignoresSiblingOrder = false
    @_sk_view
  end

	# Generally name params 'tag' for Symbol, 'label' for String.
  def go_to_scene(tag)
  	case tag
  	when :edge_scene
			sk_view.presentScene(@edge_scene)
  	when :tally_scene
			sk_view.presentScene(@tally_scene)
  	when :drag_scene
			sk_view.presentScene(@drag_scene)
		end
  end

	# Assumes anchorPoint is 0.5, 0.5. Make it work relative to set anchorPoint!!! FIXME!!!
	# in scene#beganTouches:
	#		return if self.hot_corner(touches, self)
	def hot_corner(touches, scene) #, thickness)
		touch = touches.allObjects.first
		location = touch.locationInNode(scene)
		which = ""
		which << "top" if location.y > (scene.frame.size.height/2 - 20) # -20: -thickness
		which << "bottom" if location.y < -(scene.frame.size.height/2 - 20)
		which << "left" if location.x < -(scene.frame.size.width/2 - 20)
		which << "right" if location.x > (scene.frame.size.width/2 - 20)
		if which != "" && which.length > 5 # won't send edge "top", "left" etc
			yield(which) if block_given? 
			return true
		end
		false
	end
  
  def prefersStatusBarHidden
    true
  end
 
  def dealloc
    p "Dealloc #{self}"
    super
  end
end 
