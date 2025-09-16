$insert = @"
INSERT INTO $inventoryTable
(Server_Name, Instance_Name, IP_Address, ENV, Location, SQL_Version, Edition, Product_Version, CPU_Count,
 DiskE_UsedSpaceGB, DiskE_FreeSpaceGB, DiskE_TotalSpaceGB,
 DiskF_UsedSpaceGB, DiskF_FreeSpaceGB, DiskF_TotalSpaceGB, CaptureDate)
VALUES (
    $(Escape-SqlValue $row.Server_Name),
    $(Escape-SqlValue $row.Instance_Name),
    $(Escape-SqlValue $row.IP_Address),
    $(Escape-SqlValue $row.ENV),
    $(Escape-SqlValue $row.Location),
    $(Escape-SqlValue $row.SQL_Version),
    $(Escape-SqlValue $row.Edition),
    $(Escape-SqlValue $row.Product_Version),
    $($row.CPU_Count),
    $($row.DiskE_UsedSpaceGB),
    $($row.DiskE_FreeSpaceGB),
    $($row.DiskE_TotalSpaceGB),
    $($row.DiskF_UsedSpaceGB),
    $($row.DiskF_FreeSpaceGB),
    $($row.DiskF_TotalSpaceGB),
    GETDATE()
);
"@
