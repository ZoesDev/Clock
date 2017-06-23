Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
$DegreesToRadians = [Math]::PI/180

function Initialize-Clock() {
  # create the form to display the clock
  $script:form = New-Object -TypeName Windows.Forms.Form
  $script:form.Height = 700
  $script:form.Width = 700
  $script:clockRadius = 350
  $script:CenterRadius = 15.5
  $script:lenHrHand = 133
  $script:lenMinHand = 212
  $script:lenSecHand = 212
  $script:SecondsPen = New-Object -TypeName Drawing.Pen -ArgumentList ([Drawing.Color]::Black)
  $script:MinutesPen = New-Object -TypeName Drawing.Pen -ArgumentList ([Drawing.Color]::Black)
  $script:HoursPen =  New-Object -TypeName Drawing.Pen -ArgumentList ([Drawing.Color]::Black)
  $script:TicksPen =  New-Object -TypeName Drawing.Pen -ArgumentList ([Drawing.Color]::Black)
  $script:FifthPen =  New-Object -TypeName Drawing.Pen -ArgumentList ([Drawing.Color]::Black)
  $script:CircleBrush = New-Object -TypeName Drawing.SolidBrush -ArgumentList ([Drawing.Color]::Black)
  $script:CenterPoint = New-Object -TypeName Drawing.PointF
  $script:HourPoint =  New-Object -TypeName Drawing.PointF
  $script:MinPoint =  New-Object -TypeName Drawing.PointF
  $script:SecPoint =  New-Object -TypeName Drawing.PointF
  $script:InnerPoint = New-Object -TypeName Drawing.PointF
  $script:OuterPoint = New-Object -TypeName Drawing.PointF
  $script:SpotPoint = New-Object -TypeName Drawing.PointF
  $script:CenterPoint.X = 350
  $script:CenterPoint.Y = 350
  $script:formTimer = New-Object -TypeName Windows.Forms.Timer
  $script:secondsPenWidth = 1.16
  $script:minutesPenWidth = 3.5
  $script:hoursPenWidth = 4.66
  $script:SecondsPen.Width = $secondsPenWidth
  $script:MinutesPen.Width = $minutesPenWidth
  $script:HoursPen.Width = $hoursPenWidth
  $script:TicksPen.Width = $secondsPenWidth
  $script:FifthPen.Width = $secondsPenWidth * 3
  $formTimer.Interval = 1000  # 1 second
}
$form.Invalidate() #refreshes the form
$draw_AnalogClock = {
  $graphicsObj = $form.createGraphics()
  $currentHour  = (Get-Date).Hour
  $currentMinute = (Get-Date).Minute
  $currentSecond = (Get-Date).Second
  # degrees around the circle
  $hourDegrees = 30 * ($currentHour+($currentMinute/60))
  $minuteDegrees = $currentMinute * 6
  $secondDegrees = $currentSecond * 6
  # Sin and Cos functions require angles in radians
  $hourRadian  = $hourDegrees  * $DegreesToRadians
  $minuteRadian = $minuteDegrees * $DegreesToRadians
  $secondRadian = $secondDegrees * $DegreesToRadians
  # calculate the endpoint of each hand
  $HourPoint.X = $CenterPoint.X + ($lenHrHand * [Math]::Sin($hourRadian))
  $HourPoint.Y = $CenterPoint.Y – ($lenHrHand * [Math]::Cos($hourRadian))
  $MinPoint.X = $CenterPoint.X + ($lenMinHand * [Math]::Sin($minuteRadian))
  $MinPoint.Y = $CenterPoint.Y – ($lenMinHand * [Math]::Cos($minuteRadian))
  $SecPoint.X = $CenterPoint.X + ($lenSecHand * [Math]::Sin($secondRadian))
  $SecPoint.Y = $CenterPoint.Y – ($lenSecHand * [Math]::Cos($secondRadian))
  # now draw the clock hands
  $graphicsObj.DrawLine($HoursPen,  $CenterPoint, $HourPoint)
  $graphicsObj.DrawLine($MinutesPen, $CenterPoint, $MinPoint)
  $graphicsObj.DrawLine($SecondsPen, $CenterPoint, $SecPoint)
  # draw the ticks around the outside clock face
  for ($ticks = 1; $ticks -lt 61; $ticks++) {
    $tickRadian = ($ticks * 6) * $DegreesToRadians
    $innerpoint.X = $CenterPoint.X + ($clockRadius / 1.50 * [Math]::Sin($tickRadian))
    $innerpoint.Y = $CenterPoint.Y – ($clockRadius / 1.50 * [Math]::Cos($tickRadian))
    if (($ticks % 5) -eq 0) {
    $outerpoint.X = $CenterPoint.X + ($clockRadius / 1.60 * [Math]::Sin($tickRadian))
    $outerpoint.Y = $CenterPoint.Y – ($clockRadius / 1.60 * [Math]::Cos($tickRadian))
    $graphicsObj.DrawLine($FifthPen, $innerpoint, $outerpoint)
  }
  else {
    $outerpoint.X = $CenterPoint.X + ($clockRadius / 1.55 * [Math]::Sin($tickRadian))
    $outerpoint.Y = $CenterPoint.Y – ($clockRadius / 1.55 * [Math]::Cos($tickRadian))
    $graphicsObj.DrawLine($TicksPen, $innerpoint, $outerpoint)
  }
  }
  # and draw the circle at Center
  $SpotPoint.X = $CenterPoint.X – $CenterRadius/2
  $SpotPoint.Y = $CenterPoint.Y – $CenterRadius/2
  $graphicsObj.FillEllipse($CircleBrush, $SpotPoint.X, $SpotPoint.Y, $CenterRadius, $CenterRadius)
  $graphicsObj.Dispose()
}

$dispose_AnalogClock = {
  $SecondsPen.Dispose()
  $MinutesPen.Dispose()
  $HoursPen.Dispose()
  $TicksPen.Dispose()
  $CircleBrush.Dispose()
  $formTimer.Dispose()
  $form.Dispose()
}
$load_AnalogClock = {
    $form.refresh()
}
function Start-Clock {
  Initialize-Clock
  $formTimer.add_tick($load_AnalogClock)
  $form.add_paint($draw_AnalogClock)
  $form.add_formclosed($dispose_AnalogClock)
  $formTimer.Start()
  [void]$form.ShowDialog()
}

Start-Clock