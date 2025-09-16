function Escape-SqlValue {
    param([string]$val)
    if ($null -eq $val) { return "NULL" }
    return "'" + $val.Replace("'", "''") + "'"
}
