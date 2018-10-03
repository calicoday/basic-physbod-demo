class Scene < SKScene
	def initWithSize(size)
		super
		
		self.name = "Scene"
		self.anchorPoint = CGPointMake(0.5, 0.5) 
		self.backgroundColor = UIColor.yellowColor
    
		self
	end

	def didMoveToView(view)
		self.removeAllChildren
		
    @edge_catmask = 1
    @obstacle_catmask = 2
    @ball_catmask = 4
    @hole_catmask = 8
    @leaky_catmask = 16
    
    @ball_collision = @edge_catmask | @obstacle_catmask # | @ball_catmask def not hole
    @ball_contact = @hole_catmask
    
    @obstacle_collision = @obstacle_catmask | @ball_catmask
    
		@pull_value = 2.0
		self.physicsWorld.gravity=CGVectorMake(0, -@pull_value) # default is 0,-9.8
		self.physicsWorld.contactDelegate = self
	end
	
	def add_bounds(view)
		@bounds_size = view.frame.size
		@bounds_size.width -= 100
		@bounds_size.height -= 150

		@bounds = SKShapeNode.shapeNodeWithRectOfSize(@bounds_size)
		@bounds.name = "Bounds"
		@bounds.lineWidth = 2.0
		@bounds.strokeColor = UIColor.blueColor

		@bounds.physicsBody = SKPhysicsBody.bodyWithEdgeLoopFromRect(@bounds.frame)
		@bounds.physicsBody.categoryBitMask = @edge_catmask 

		addChild(@bounds)
	end

	def add_ball(position)
		ball = SKSpriteNode.spriteNodeWithImageNamed("cyanball.png")
		ball.position = position
		ball.xScale = 0.5
		ball.yScale = 0.5
		ball.name = "Ball"

		ball.physicsBody = SKPhysicsBody.bodyWithCircleOfRadius(27 * ball.xScale)
		ball.physicsBody.categoryBitMask = @ball_catmask
		ball.physicsBody.collisionBitMask = @ball_collision
		
		addChild(ball)
	end

	def hot_corner(touches, scene)
		self.view.window.rootViewController.hot_corner(
					touches, self) { |label| do_hot_corner(label) }
	end

	def do_hot_corner(label)
		case label
		when "bottomleft" then on_hot_bottomleft
		when "bottomright" then on_hot_bottomright
		when "topleft" then on_hot_topleft
		when "topright" then on_hot_topright
		end
	end
	
	def on_hot_bottomleft
	end
	def on_hot_bottomright
	end
	def on_hot_topleft
	end
	def on_hot_topright
	end
end
