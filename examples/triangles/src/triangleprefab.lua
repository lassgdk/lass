return {
  name = "Triangle",
  transform = {
    position = {
      x = 0,
      y = 0,
      z = 0
    },
    rotation = 0,
  },
  components = {
    {
      script = "lass.builtins.graphics.ShapeRenderer",
      arguments = {
        color = {6, 94, 206},
        -- vertices = {-100, -50, 100, -50, 0, 50},
        shape = {"Polygon", {-100, -50, 100, -50, 0, 50}},
      }
    },
    {
      script = "lass.builtins.physics.Collider",
      arguments = {
        shapeSource = {"gameObject", "getComponent", "lass.builtins.graphics.Renderer"}
      }
    },
    {
      script = "PlayerInput",
      arguments = {
        rotationSpeed = 1,
        speedMode = "perFrame"
      }
    }
  }
}
