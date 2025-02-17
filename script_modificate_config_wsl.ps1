# Пути к файлам (при необходимости укажите полный путь)
$wslConfigPath = "config-wsl" # базовый конфиг версии ядра 5.15.167.4
$wslOrigPath = "config-wsl_orig" # базовый конфиг версии ядра 6.6.75.1
$outputPath = "config-wsl_orig_modified" # модифицированый конфиг ядра 6.6.75.1

# Создаем хэш-таблицу для параметров из config-wsl, где значение равно "y"
$dict = @{}

Get-Content $wslConfigPath | ForEach-Object {
    $line = $_.Trim()
    if ($line -match '^(CONFIG_[^=]+)=(.+)$') {
        $key = $matches[1]
        $value = $matches[2].Trim()
        if ($value -eq "y") {
            $dict[$key] = $true
        }
    }
}

# Обрабатываем файл config-wsl_orig и формируем обновленный файл
$outputLines = Get-Content $wslOrigPath | ForEach-Object {
    $line = $_
    if ($line -match '^(CONFIG_[^=]+)=(.+)$') {
        $key = $matches[1]
        $value = $matches[2].Trim()
        # Если в config-wsl для этого ключа значение равно "y" и в config-wsl_orig установлено "m",
        # заменяем его на "y"
        if ($dict.ContainsKey($key) -and $value -eq "m") {
            return "$key=y"
        } else {
            return $line
        }
    } else {
        return $line
    }
}

# Сохраняем результат в новый файл
$outputLines | Set-Content $outputPath

Write-Host "Обновленный конфиг сохранен в файле: $outputPath"
