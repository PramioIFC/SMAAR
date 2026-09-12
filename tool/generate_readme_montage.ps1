Add-Type -AssemblyName System.Drawing

$outDir = Join-Path $PSScriptRoot '..\docs\images'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$calendarPath = Join-Path $outDir 'calendario.png'
$bitmap = New-Object Drawing.Bitmap 390, 844
$g = [Drawing.Graphics]::FromImage($bitmap)
$g.SmoothingMode = 'AntiAlias'
$g.Clear([Drawing.Color]::FromArgb(248, 249, 250))

$black = New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(30, 30, 30))
$gray = New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(110, 110, 110))
$green = New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(76, 175, 80))
$red = New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(211, 47, 47))
$orange = New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(255, 152, 0))
$title = [Drawing.Font]::new('Segoe UI', 21, [Drawing.FontStyle]::Bold)
$body = [Drawing.Font]::new('Segoe UI', 14, [Drawing.FontStyle]::Regular)
$small = [Drawing.Font]::new('Segoe UI', 10, [Drawing.FontStyle]::Bold)

$g.DrawString('X', ([Drawing.Font]::new('Segoe UI', 24)), $black, 18, 15)
$g.DrawString('<', $title, $black, 22, 82)
$g.DrawString('Setembro 2026', $title, $black, 105, 82)
$g.DrawString('>', $title, $black, 345, 82)

$week = @('SEG','TER','QUA','QUI','SEX','SAB','DOM')
for ($i = 0; $i -lt 7; $i++) {
  $g.DrawString($week[$i], $small, $gray, 18 + ($i * 52), 135)
}

$offset = 1
for ($day = 1; $day -le 30; $day++) {
  $cell = $offset + $day - 1
  $col = $cell % 7
  $row = [Math]::Floor($cell / 7)
  $x = 20 + ($col * 52)
  $y = 178 + ($row * 72)
  if ($day -eq 12) {
    $g.FillEllipse($green, $x - 7, $y - 10, 42, 42)
    $g.DrawString($day, $body, [Drawing.Brushes]::White, $x + 1, $y)
  } else {
    $g.DrawString($day, $body, $black, $x, $y)
  }
  if ($day -in @(2, 7, 9, 12, 16, 21, 25, 29)) {
    $dot = if ($day -in @(7, 21)) { $red } elseif ($day -eq 16) { $orange } else { $green }
    $g.FillEllipse($dot, $x + 8, $y + 30, 7, 7)
  }
}

$g.FillRectangle([Drawing.Brushes]::White, 16, 565, 358, 180)
$g.DrawString('Legenda', $title, $black, 35, 585)
$g.FillEllipse($green, 38, 635, 12, 12); $g.DrawString('Uso normal', $body, $black, 62, 627)
$g.FillEllipse($orange, 38, 675, 12, 12); $g.DrawString('Alerta / Atencao', $body, $black, 62, 667)
$g.FillEllipse($red, 38, 715, 12, 12); $g.DrawString('Problema / Falha', $body, $black, 62, 707)
$bitmap.Save($calendarPath, [Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bitmap.Dispose()

# O runner de golden usa uma fonte de teste para alguns TextSpans em negrito.
# Recoloca os dados reais da ultima atividade com fonte legivel.
$gatePath = Join-Path $outDir 'gerenciar-porteira.png'
$gateSource = [Drawing.Image]::FromFile($gatePath)
$gateBitmap = New-Object Drawing.Bitmap 390, 844
$gateScale = [Drawing.Graphics]::FromImage($gateBitmap)
$gateScale.DrawImage($gateSource, 0, 0, 390, 844)
$gateScale.Dispose()
$gateSource.Dispose()
$gg = [Drawing.Graphics]::FromImage($gateBitmap)
$gg.FillRectangle([Drawing.Brushes]::White, 79, 390, 270, 86)
$activityBold = [Drawing.Font]::new('Segoe UI', 12, [Drawing.FontStyle]::Bold)
$activitySmall = [Drawing.Font]::new('Segoe UI', 10, [Drawing.FontStyle]::Regular)
$activityRed = New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(163, 45, 45))
$gg.DrawString('07:15  Porteira aberta', $activityBold, $activityRed, 80, 402)
$gg.DrawString('Abertura registrada', $activitySmall, $activityRed, 80, 428)
$gateBitmap.Save($gatePath, [Drawing.Imaging.ImageFormat]::Png)
$gg.Dispose(); $gateBitmap.Dispose()

$files = @('porteiras.png', 'gerenciar-porteira.png', 'historico-do-dia.png', 'calendario.png')
$labels = @('MINHAS PORTEIRAS', 'GERENCIAR PORTEIRA', 'HISTORICO DO DIA', 'CALENDARIO')
$panel = New-Object Drawing.Bitmap 840, 1810
$pg = [Drawing.Graphics]::FromImage($panel)
$pg.Clear([Drawing.Color]::White)
$labelFont = [Drawing.Font]::new('Segoe UI', 17, [Drawing.FontStyle]::Bold)

for ($i = 0; $i -lt 4; $i++) {
  $x = 20 + (($i % 2) * 410)
  $y = 55 + ([Math]::Floor($i / 2) * 890)
  $pg.DrawString($labels[$i], $labelFont, $black, $x, $y - 38)
  $image = [Drawing.Image]::FromFile((Join-Path $outDir $files[$i]))
  $pg.DrawImage($image, $x, $y, 390, 844)
  $image.Dispose()
}

$panel.Save((Join-Path $outDir 'smaar-telas.png'), [Drawing.Imaging.ImageFormat]::Png)
$pg.Dispose(); $panel.Dispose()
