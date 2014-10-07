return {settings = {
  window = {
    width = 800,
    height = 600
  },
  graphics = {
    backgroundColor = {255,255,255},
    invertYAxis = true
  }
}, gameObjects = {
  {
    name = "Player",
    transform = {
      position = {
        x = 200,
        y = -100,
        z = 1
      },
      rotation = 0,
    },
    components = {
      {
        _module = "Polygon",
        properties = {
          color = {0, 0, 80},
          vertices = {-100, -50, 100, -50, 0, 50}
        }
      },
      {
        _module = "PlayerInput",
        properties = {
          rotationSpeed = 1,
          speedMode = "perFrame"
        }
      }
    },
    children = {
      {
        name = "Satellite",
        transform = {
          position = {
            x = 100,
            y = 10
          }
        },
        components = {
          {
            _module = "Polygon",
            properties = {
              color = {200, 0, 80},
              vertices = {-100, -50, 100, -50, 0, 50}
            }
          },
        },
        children = {
          {
            name = "SubSatellite",
            transform = {
              position = {
                x = 200,
                y = 0
              }
            },
            components = {
              {
                _module = "Polygon",
                properties = {
                  color = {200, 0, 80},
                  vertices = {-100, -50, 100, -50, 0, 50}
                }
              },
            }
          }
        }
      }
    }
  }
}}