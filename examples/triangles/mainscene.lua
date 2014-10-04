return {
  {
    name = "Player",
    transform = {
      position = {
        x = 200,
        y = 100,
        z = 1
      },
      rotation = 0,
    },
    components = {
      {
        _module = "Polygon",
        properties = {
          color = {0, 0, 80},
          vertices = {-100, 0, 100, 0, 0, 100}
        }
      },
      {
        _module = "PlayerInput",
        properties = {
          speed = 10,
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
              vertices = {-100, 0, 100, 0, 0, 100}
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
                  vertices = {-100, 0, 100, 0, 0, 100}
                }
              },
            }
          }
        }
      }
    }
  }
}