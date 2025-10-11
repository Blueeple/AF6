return {
	Integer = {
		Read = function(value: number): number
			assert(type(value) == "number", "Value must be a number")
			assert(value % 1 == 0, "Value must be an integer")
			return value
		end,
		Write = function(value: number): number
			assert(type(value) == "number", "Value must be a number")
			assert(value % 1 == 0, "Value must be an integer")
			return value
		end,
	},
	Floatu8 = {
		Read = function(value: number): number
			assert(type(value) == "number", "Value must be a number")
			assert(value >= 0 and value <= 255, "Value must be between 0 and 255")
			return value
		end,
		Write = function(value: number): number
			assert(type(value) == "number", "Value must be a number")
			assert(value >= 0 and value <= 255, "Value must be between 0 and 255")
			return value
		end,
	},
	--[=[
		**WARNING**: RBXUnCompressed is not recommended due to security reasons and requires you to turn off {PlaceHolderSetting}, which includes:
		
		* Exploiters can pass almost any type.
		* Requires custom security checks in your script.
		* Pretty much just raw Roblox's default remote events.

		**NOTICE**: If your sending a table or array caching them directly with ModNet is HEAVILY recommended.

		**Example (Caching):**

		```
		local TableToCache = {
			Apple = 1,
			Banana = 2,
			Orange = 3,
		}

		ModNet.CacheTable("ExampleTable", TableToCache)
		```

		**Example (Sending):**

		```
		local DataToSend = ModNet.SendTable({
			Apple = 16,
			Banana = 21,
			Orange = 17,
		})
		```
	]=]
	RBXUnCompressed = {
		Read = function(value: any): ...any
			return value
		end,
		Write = function(value: any): ...any
			return value
		end,
	},
}
