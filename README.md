![esx_n0chteil_blackbox|690x401](https://forum.cfx.re/uploads/default/original/4X/1/a/d/1ad80f7881a4005e76bd825f62314806ad702c30.jpeg)

**Requirements**
* ESX/es_extended (not tested with ESX final)

**FiveM post**

https://forum.cfx.re/t/free-esx-plane-heli-blackbox/4769163

**Video**

https://streamable.com/f0n9t2


**Menu example**

*esx_policejob/client/main.lua*

Search for **data.current.value == 'vehicle_interaction'**

Change these things:
```
if DoesEntityExist(vehicle) then
   table.insert(elements, {label = _U('vehicle_info'), value = 'vehicle_infos'})
   table.insert(elements, {label = _U('pick_lock'), value = 'hijack_vehicle'})
   table.insert(elements, {label = _U('impound'), value = 'impound'})
   if GetVehicleClass(vehicle) == 15 or GetVehicleClass(vehicle) == 16 then
      table.insert(elements, {label = "Check Blackbox", value = 'blackbox'})
   end
end
```
```
if action == "search_database" then
    LookupVehicle()
elseif action == "blackbox" then
    ESX.TriggerServerCallback("esx_blackbox:getEntry", function(data)
            local elements = {}

            for i = 1, #data, 1 do
                table.insert(elements, {label = "Entry " .. i, value = data[i]})
            end

            ESX.UI.Menu.Open("default", GetCurrentResourceName(), "blackbox_interaction", {
                    title = "Blackbox data",
                    align = "top-left",
                    elements = elements
                }, function(data3, menu3)
                    ESX.UI.Menu.Open( "default", GetCurrentResourceName(), "blackbox_entry",
                        {
                            title = "Blackbox data",
                            align = "top-left",
                            elements = {
                                {label = "View record", value = "view_rec"},
                                {label = "Delete entry", value = "delete"}
                            }
                        }, function(data4, menu4)
                            if data4.current.value == "view_rec" then
                                TriggerEvent("esx_blackbox:viewRecord", data3.current.value)
                            elseif data4.current.value == "delete" then
                                TriggerServerEvent("esx_blackbox:deleteEntry", "entry", data3.current.value)
                                menu4.close()
                                menu3.close()
                            end
                        end, function(data4, menu4)
                            menu4.close()
                        end)
                end, function(data3, menu3)
                    menu3.close()
                end)
        end, "plate", GetVehicleNumberPlateText(vehicle))
elseif DoesEntityExist(vehicle) then
```

**Information**
* The planes/helicopters are spawned locally
* Use **/removeBlackboxVeh** to delete the spawned vehicles
* I know it is not perfect at the moment
