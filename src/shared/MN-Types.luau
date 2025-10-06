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
	RBXUnCompressed = {
		Read = function(value: any): any
			return value
		end,
		Write = function(value: any): any
			return value
		end,
	},
	
}
