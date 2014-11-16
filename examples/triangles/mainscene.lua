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
    name = "Triangle",
    prefab = "triangleprefab",
    transform = {
      position = {
        x = 200,
        y = -200,
        z = 1
      },
      rotation = 0,
    },
    children = {
      {
        name = "Satellite",
        prefab = "triangleprefab",
        transform = {
          position = {
            x = 200,
            y = 10,
            z = 1
          },
          size = {
            x = .9,
            y = .9,
          }
        },
        prefabComponents = {
          script = "lass.builtins.graphics.PolygonRenderer",
          arguments = {
            color = {200, 0, 80}
          }
        },
        -- components = {
        --   {
        --     script = "lass.builtins.graphics.PolygonRenderer",
        --     arguments = {
        --       color = {200, 0, 80},
        --       vertices = {-100, -50, 100, -50, 0, 50}
        --     }
        --   },
        --   {
        --     script = "lass.builtins.colliders.PolygonCollider",
        --     arguments = {
        --       verticesSource = "lass.builtins.graphics.PolygonRenderer"
        --     }
        --   },
        --   {
        --     script = "PlayerInput",
        --     arguments = {
        --       rotationSpeed = 1,
        --       speedMode = "perFrame"
        --     }
        --   }
        -- },
        children = {
          {
            name = "SubSatellite",
            transform = {
              position = {
                x = 200,
                y = 0,
                z = 1
              }
            },
            components = {
              {
                script = "lass.builtins.graphics.PolygonRenderer",
                arguments = {
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