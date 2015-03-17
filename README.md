# GooeySlider
Slider with discrete values and a gooey indicator

![Animated demo]
(https://github.com/278204/GooeySlider/blob/master/GooeySelect/gooeySlider.gif)

Just add the GooeySelect directory to your project and add the following code to add the slider.

```Swift
let select = GooeySelect(frame: CGRect(x: 20, y: 400, width: 280, height: 50))
select.delegate = self
select.color = UIColor.redColor()
select.showProgessLine = true
select.numberOfOptions = 5

self.view.addSubview(select)
```


