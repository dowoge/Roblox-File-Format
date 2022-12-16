--!strict
local HttpService = game:GetService("HttpService")

export type GetSet = string | {
	Get: string,
	Set: string,
	Flags: string?,
}

export type Patch = {
	Add: { [string]: string }?,
	Redirect: { [string]: GetSet }?,
	Defaults: { [string]: any }?,
	Remove: { string }?,
}

-- strict type reaffirmation?
-- this is some bug with Luau.

local function GetSet(getSet: GetSet): GetSet
	return getSet
end

local function UseColor3(propName: string): GetSet
	return {
		Get = string.format("BrickColor.FromColor3(%s)", propName),
		Set = propName .. " = value?.Color",
	}
end

local function TryDefineEnum(enumName: string): string?
	local gotEnum, enum = pcall(function()
		return (Enum :: any)[enumName] :: Enum
	end)

	if gotEnum then
		return "Enum:" .. tostring(enum)
	end

	return nil
end

local function TryGetEnumItem(enumName, itemName): EnumItem?
	local gotEnum, enum = pcall(function()
		return (Enum :: any)[enumName] :: Enum
	end)

	if gotEnum then
		local gotEnumItem, item = pcall(function()
			return (enum :: any)[itemName] :: EnumItem
		end)

		if gotEnumItem then
			return item
		end
	end

	return nil
end

local GuiTextMixIn: Patch = {
	Add = { Transparency = "float" },

	Redirect = {
		Font = GetSet({
			Get = "FontUtility.GetLegacyFont(FontFace)",
			Set = "FontUtility.TryGetFontFace(value, out FontFace)",
		}),

		FontSize = GetSet({
			Get = "FontUtility.GetFontSize(TextSize)",
			Set = "TextSize = FontUtility.GetFontSize(value)",
		}),

		TextColor = UseColor3("TextColor3"),
		TextWrap = GetSet("TextWrapped"),

		Transparency = GetSet({
			Get = "base.Transparency",
			Set = "base.Transparency = value;\nTextTransparency  = value;",
			Flag = "new",
		}),
	},
}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local PropertyPatches: { [string]: Patch } = {
	AnimationRigData = {
		Add = {
			name = "BinaryString",
			label = "BinaryString",
			parent = "BinaryString",
			weight = "BinaryString",
			transform = "BinaryString",
			facsControl = "BinaryString",
			preTransform = "BinaryString",
			postTransform = "BinaryString",
			articulatedJoint = "BinaryString",
			endEffectorRotationConstraint = "BinaryString",
			endEffectorTranslationConstraint = "BinaryString",
		},

		Defaults = {
			name = "AQAAAAEAAAAAAAAA",
			label = "AQAAAAEAAAAAAAAA",
			parent = "AQAAAAEAAAAAAA==",

			transform = "AQAAAAEAAAAAAIA/AAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAA=",
			preTransform = "AQAAAAEAAAAAAIA/AAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAA=",
			postTransform = "AQAAAAEAAAAAAIA/AAAAAAAAAAAAAAAAAACAPwAAAAAAAAAAAAAAAAAAgD8AAAAAAAAAAAAAAAA=",

			weight = "AQAAAAAAAAA=",
			facsControl = "AQAAAAAAAAA=",
			articulatedJoint = "AQAAAAAAAAA=",
			endEffectorRotationConstraint = "AQAAAAAAAAA=",
			endEffectorTranslationConstraint = "AQAAAAAAAAA=",
		},
	},

	BallSocketConstraint = {
		-- Why does this even exist?
		Add = {
			MaxFrictionTorqueXml = "float",
			MaxFrictionTorque = "float",
		},

		Redirect = {
			MaxFrictionTorque = GetSet("MaxFrictionTorqueXml"),
		},
	},

	BasePart = {
		Add = {
			MaterialVariantSerialized = "string",
			MaterialVariant = "string",
			Color3uint8 = "Color3uint8",
			size = "Vector3",
		},

		Redirect = {
			Position = GetSet({
				Get = "CFrame.Position",
				Set = "CFrame = new CFrame(value) * CFrame.Rotation",
			}),

			MaterialVariant = GetSet("MaterialVariantSerialized"),
			BrickColor = UseColor3("Color"),
			Color = GetSet("Color3uint8"),
			Size = GetSet("size"),
		},

		Defaults = {
			Color3uint8 = Color3.fromRGB(163, 162, 165),
			MaterialVariantSerialized = "",
			size = Vector3.new(4, 1.2, 2),
		},
	},

	BaseScript = {
		Remove = { "LinkedSource" },
	},

	BevelMesh = {
		Add = {
			Bevel = "float",
			Bevel_Roundness = "float",
			Bulge = "float",
		},
	},

	BinaryStringValue = {
		Add = { Value = "BinaryString" },
	},

	BodyColors = {
		Redirect = {
			HeadColor = UseColor3("HeadColor3"),
			LeftArmColor = UseColor3("LeftArmColor3"),
			RightArmColor = UseColor3("RightArmColor3"),
			LeftLegColor = UseColor3("LeftLegColor3"),
			RightLegColor = UseColor3("RightLegColor3"),
			TorsoColor = UseColor3("TorsoColor3"),
		},
	},

	BodyAngularVelocity = {
		Redirect = { angularvelocity = GetSet("AngularVelocity") },
	},

	BodyGyro = {
		Redirect = { cframe = GetSet("CFrame") },
	},

	Camera = {
		Redirect = { CoordinateFrame = GetSet("CFrame") },
	},

	CustomEvent = {
		Add = { PersistedCurrentValue = "float" },
	},

	DataModelMesh = {
		Add = {
			LODX = TryDefineEnum("LevelOfDetailSetting"),
			LODY = TryDefineEnum("LevelOfDetailSetting"),
		},

		Defaults = {
			LODX = TryGetEnumItem("LevelOfDetailSetting", "High"),
			LODY = TryGetEnumItem("LevelOfDetailSetting", "High"),
		},
	},

	DataStoreService = {
		Defaults = {
			AutomaticRetry = true,
			LegacyNamingScheme = false,
		},
	},

	DoubleConstrainedValue = {
		Add = { value = "double" },

		Redirect = {
			Value = GetSet("value"),
			ConstrainedValue = GetSet("value"),
		},
	},

	Fire = {
		Add = {
			heat_xml = "float",
			size_xml = "float",
		},

		Defaults = {
			heat_xml = 9,
			size_xml = 5,
		},

		Redirect = {
			Heat = GetSet("heat_xml"),
			Size = GetSet("size_xml"),
		},
	},

	FloatCurve = {
		Add = { ValuesAndTimes = "BinaryString" },
		Defaults = { ValuesAndTimes = "AAAAAAEAAAAKAAAAAAAAFkUAAAAA" },
	},

	FormFactorPart = {
		Add = {
			formFactorRaw = TryDefineEnum("FormFactor"),
		},

		Defaults = {
			formFactorRaw = TryGetEnumItem("FormFactor", "Brick"),
		},

		Redirect = {
			FormFactor = GetSet("formFactorRaw"),
		},
	},

	FunctionalTest = {
		Add = { HasMigratedSettingsToTestService = "bool" },
		Defaults = { HasMigratedSettingsToTestService = false },
	},

	GuiBase2d = {
		Redirect = { Localize = GetSet("AutoLocalize") },
	},

	GuiBase3d = {
		Redirect = { Color = UseColor3("Color3") },
	},

	GuiObject = {
		Redirect = {
			Transparency = GetSet("BackgroundTransparency"),
			BackgroundColor = UseColor3("BackgroundColor3"),
			BorderColor = UseColor3("BorderColor3"),
		},
	},

	HiddenSurfaceRemovalAsset = {
		Add = {
			HSRData = "BinaryString",
			HSRMeshIdData = "BinaryString",
		},
	},

	HttpService = {
		Defaults = { HttpEnabled = false },
	},

	Humanoid = {
		Add = {
			Health_XML = "float",
			InternalHeadScale = "float",
			InternalBodyScale = "Vector3",
		},

		Defaults = {
			Health_XML = 100,
			InternalHeadScale = 1,
			InternalBodyScale = Vector3.new(1, 1, 1),
		},

		Redirect = {
			Health = GetSet("Health_XML"),
		},

		Remove = {
			"Jump",
			"Torso",
			"LeftLeg",
			"RightLeg",
		},
	},

	HumanoidDescription = {
		Add = {
			EmotesDataInternal = "string",
			EquippedEmotesDataInternal = "string",
		},

		Defaults = {
			AccessoryBlob = "[]",
			EmotesDataInternal = "[]",
			EquippedEmotesDataInternal = "[]",
		},
	},

	InsertService = {
		Add = { AllowClientInsertModels = "bool" },
		Defaults = { AllowClientInsertModels = false },
	},

	IntConstrainedValue = {
		Add = { value = "int64" },

		Redirect = {
			Value = GetSet("value"),
			ConstrainedValue = GetSet("value"),
		},
	},

	Lighting = {
		Add = {
			Technology = TryDefineEnum("Technology"),
		},

		Defaults = {
			Technology = TryGetEnumItem("Technology", "Compatibility"),
		},
	},

	LocalizationTable = {
		Add = { Contents = "string" },
		Defaults = { Contents = "[]" },

		Redirect = {
			DevelopmentLanguage = GetSet("SourceLocaleId"),
		},
	},

	LocalScript = {
		Remove = {
			"LinkedSource",
			"Source",
		},
	},

	LuaSourceContainer = {
		Add = {
			LinkedSource = "Content",
			ScriptGuid = "string",
			Source = "ProtectedString",
		},
	},

	MarkerCurve = {
		Add = { ValuesAndTimes = "BinaryString" },
		Defaults = { ValuesAndTimes = "AAAAAAEAAAAKAAAAAAAAFkUAAAAA" },
	},

	MaterialService = {
		Add = {
			Use2022Materials = "bool",
			Use2022MaterialsXml = "bool",
		},

		Redirect = { Use2022Materials = GetSet("Use2022MaterialsXml") },

		Defaults = {
			AsphaltName = "Asphalt",
			BasaltName = "Basalt",
			BrickName = "Brick",
			CobblestoneName = "Cobblestone",
			ConcreteName = "Concrete",
			CorrodedMetalName = "CorrodedMetal",
			CrackedLavaName = "CrackedLava",
			DiamondPlateName = "DiamondPlate",
			FabricName = "Fabric",
			FoilName = "Foil",
			GlacierName = "Glacier",
			GraniteName = "Granite",
			GrassName = "Grass",
			GroundName = "Ground",
			IceName = "Ice",
			LeafyGrassName = "LeafyGrass",
			LimestoneName = "Limestone",
			MarbleName = "Marble",
			MetalName = "Metal",
			MudName = "Mud",
			PavementName = "Pavement",
			PebbleName = "Pebble",
			PlasticName = "Plastic",
			RockName = "Rock",
			SaltName = "Salt",
			SandName = "Sand",
			SandstoneName = "Sandstone",
			SlateName = "Slate",
			SmoothPlasticName = "SmoothPlastic",
			SnowName = "Snow",
			WoodName = "Wood",
			WoodPlanksName = "WoodPlanks",
		},
	},

	MaterialVariant = {
		Add = {
			TexturePack0 = "Content",
			TexturePack1 = "Content",
		},
	},

	MeshPart = {
		Add = { VertexCount = "int" },
		Defaults = { VertexCount = 0 },
		Redirect = { MeshID = GetSet("MeshId") },
	},

	Model = {
		Add = {
			ModelMeshCFrame = "CFrame",
			ModelMeshData = "SharedString",
			ModelMeshSize = "Vector3",
			NeedsPivotMigration = "bool",
			WorldPivotData = "Optional<CFrame>",
		},
	},

	ModuleScript = {
		Remove = {
			"LinkedSource",
			"Source",
		},
	},

	PackageLink = {
		Add = {
			VersionIdSerialize = "int64",
			PackageIdSerialize = "Content",
		},

		Defaults = { AutoUpdate = false },
	},

	Part = {
		Add = { shape = TryDefineEnum("PartType") },
		Redirect = { Shape = GetSet("shape") },
	},

	ParticleEmitter = {
		Redirect = {
			VelocitySpread = GetSet({
				Get = "SpreadAngle.X",
				Set = "SpreadAngle = new Vector2(value, value)",
			}),
		},
	},

	PartOperation = {
		Add = {
			AssetId = "Content",

			ChildData = "BinaryString",
			ChildData2 = "SharedString",

			MeshData = "BinaryString",
			MeshData2 = "SharedString",

			FormFactor = TryDefineEnum("FormFactor"),
		},

		Defaults = { FormFactor = Enum.FormFactor.Custom },
	},

	PartOperationAsset = {
		Add = {
			ChildData = "BinaryString",
			MeshData = "BinaryString",
		},
	},

	Players = {
		Defaults = { MaxPlayersInternal = 16 },
	},

	PolicyService = {
		Add = {
			IsLuobuServer = TryDefineEnum("TriStateBoolean"),
			LuobuWhitelisted = TryDefineEnum("TriStateBoolean"),
		},

		Defaults = {
			IsLuobuServer = TryGetEnumItem("TriStateBoolean", "Unknown"),
			LuobuWhitelisted = TryGetEnumItem("TriStateBoolean", "Unknown"),
		},
	},

	RotationCurve = {
		Add = { ValuesAndTimes = "BinaryString" },
		Defaults = { ValuesAndTimes = "AAAAAAEAAAAKAAAAAAAAFkUAAAAA" },
	},

	SelectionBox = {
		Redirect = { SurfaceColor = UseColor3("SurfaceColor3") },
	},

	SelectionSphere = {
		Redirect = { SurfaceColor = UseColor3("SurfaceColor3") },
	},

	ServerScriptService = {
		Defaults = { LoadStringEnabled = false },
	},

	Script = {
		Remove = {
			"LinkedSource",
			"Source",
		},
	},

	ScriptDebugger = {
		Add = {
			CoreScriptIdentifier = "string",
			ScriptGuid = "string",
		},
	},

	Smoke = {
		Add = {
			size_xml = "float",
			opacity_xml = "float",
			riseVelocity_xml = "float",
		},

		Defaults = {
			size_xml = 1,
			opacity_xml = 0.5,
			riseVelocity_xml = 1,
		},

		Redirect = {
			Size = GetSet("size_xml"),
			Opacity = GetSet("opacity_xml"),
			RiseVelocity = GetSet("riseVelocity_xml"),
		},
	},

	Sound = {
		Add = {
			MaxDistance = "float", -- ?!
			xmlRead_MaxDistance_3 = "float",
			xmlRead_MinDistance_3 = "float",
		},

		Defaults = {
			xmlRead_MinDistance_3 = 10,
			xmlRead_MaxDistance_3 = 10000,
		},

		Redirect = {
			MaxDistance = GetSet("xmlRead_MaxDistance_3"),
			xmlRead_MinDistance_3 = GetSet("EmitterSize"),
			RollOffMinDistance = GetSet("EmitterSize"),
			MinDistance = GetSet("EmitterSize"),
			Pitch = GetSet("PlaybackSpeed"),
		},
	},

	Sparkles = {
		Redirect = { Color = GetSet("SparkleColor") },
	},

	StarterPlayer = {
		Add = {
			LoadCharacterLayeredClothing = "Enum:LoadCharacterLayeredClothing",
		},

		Defaults = {
			GameSettingsAvatar = Enum.GameAvatarType.R15,
			GameSettingsR15Collision = Enum.R15CollisionType.OuterBox,
			LoadCharacterLayeredClothing = Enum.LoadCharacterLayeredClothing.Default,

			GameSettingsScaleRangeHead = NumberRange.new(0.95, 1.00),
			GameSettingsScaleRangeWidth = NumberRange.new(0.70, 1.00),
			GameSettingsScaleRangeHeight = NumberRange.new(0.90, 1.05),
			GameSettingsScaleRangeBodyType = NumberRange.new(0.00, 1.00),
			GameSettingsScaleRangeProportion = NumberRange.new(0.00, 1.00),
		},
	},

	StudioData = {
		Add = {
			CommitInflightGuid = "string",
			CommitInflightAuthorId = "int64",
			CommitInflightPlaceVersion = "int",
		},
	},

	SurfaceAppearance = {
		Defaults = { AlphaMode = Enum.AlphaMode.Overlay },
	},

	TextBox = GuiTextMixIn,
	TextLabel = GuiTextMixIn,
	TextButton = GuiTextMixIn,

	Terrain = {
		Add = {
			AcquisitionMethod = TryDefineEnum("TerrainAcquisitionMethod"),
			ClusterGridV3 = "BinaryString",
			PhysicsGrid = "BinaryString",
			SmoothGrid = "BinaryString",
		},

		Defaults = {
			Decoration = false,
			SmoothGrid = "AQU=",
			PhysicsGrid = "AgMAAAAAAAAAAAAAAAA=",
			AcquisitionMethod = TryGetEnumItem("TerrainAcquisitionMethod", "None"),
			MaterialColors = "AAAAAAAAan8/P39rf2Y/ilY+j35fi21PZmxvZbDqw8faiVpHOi4kHh4lZlw76JxKc3trhHtagcLgc4RKxr21zq2UlJSM",
		},
	},

	TerrainDetail = {
		Add = { TexturePack = "Content" },
	},

	TerrainRegion = {
		Add = {
			ExtentsMax = "Vector3int16",
			ExtentsMin = "Vector3int16",

			GridV3 = "BinaryString",
			SmoothGrid = "BinaryString",
		},

		Defaults = {
			ExtentsMax = Vector3int16.new(),
			ExtentsMin = Vector3int16.new(),

			GridV3 = "",
			SmoothGrid = "AQU=",
		},
	},

	TextChatService = {
		Defaults = {
			CreateDefaultCommands = true,
			CreateDefaultTextChannels = true,
		},
	},

	TriangleMeshPart = {
		Add = {
			InitialSize = "Vector3",
			LODData = "BinaryString",
			PhysicsData = "BinaryString",
			PhysicalConfigData = "SharedString",
		},

		Defaults = {
			InitialSize = Vector3.new(1, 1, 1),
			PhysicalConfigData = "1B2M2Y8AsgTpgAmY7PhCfg==",
		},
	},

	TrussPart = {
		Add = { style = TryDefineEnum("Style") },
		Redirect = { Style = GetSet("style") },
	},

	UnvalidatedAssetService = {
		Add = { CachedData = "string" },

		Defaults = {
			CachedData = HttpService:JSONEncode({
				users = {},
				lastSaveTime = 0,
				lastKnownPublishRequest = 0,
			}),
		},
	},

	UserInputService = {
		Add = { LegacyInputEventsEnabled = "bool" },
		Defaults = { LegacyInputEventsEnabled = true },
	},

	ViewportFrame = {
		Add = {
			CameraCFrame = "CFrame",
			CameraFieldOfView = "float",
		},

		Defaults = {
			CameraCFrame = CFrame.new(),
			CameraFieldOfView = 70,
		},
	},

	WeldConstraint = {
		Add = {
			Part0Internal = "Class:BasePart",
			Part1Internal = "Class:BasePart",

			EnabledInternal = "bool",
			State = "int",

			CFrame0 = "CFrame",
			CFrame1 = "CFrame",
		},

		Defaults = {
			CFrame0 = CFrame.new(),
			CFrame1 = CFrame.new(),

			EnabledInternal = true,
			State = 3,

			Part0 = Instance.new("Part"),
			Part1 = Instance.new("Part"),
		},

		Redirect = {
			Part0 = GetSet("Part0Internal"),
			Part1 = GetSet("Part1Internal"),
			Enabled = GetSet("EnabledInternal"),
		},
	},

	Workspace = {
		Add = {
			CollisionGroups = "string",

			ExplicitAutoJoints = "bool",
			TerrainWeldsFixed = "bool",

			StreamingMinRadius = "int",
			StreamingTargetRadius = "int",

			MeshPartHeads = TryDefineEnum("MeshPartHeads"),
			SignalBehavior = TryDefineEnum("SignalBehavior"),
			StreamingPauseMode = TryDefineEnum("StreamingPauseMode"),
			PhysicsSteppingMethod = TryDefineEnum("PhysicsSteppingMethod"),
			MeshPartHeadsAndAccessories = TryDefineEnum("MeshPartHeadsAndAccessories"),
		},

		Defaults = {
			CollisionGroups = "Default^0^1",

			TouchesUseCollisionGroups = false,
			ExplicitAutoJoints = true,
			TerrainWeldsFixed = true,

			StreamingMinRadius = 64,
			StreamingTargetRadius = 1024,

			MeshPartHeads = TryGetEnumItem("MeshPartHeads", "Default"),
			SignalBehavior = TryGetEnumItem("SignalBehavior", "Default"),
			StreamingPauseMode = TryGetEnumItem("StreamingPauseMode", "Default"),
			PhysicsSteppingMethod = TryGetEnumItem("PhysicsSteppingMethod", "Default"),
			MeshPartHeadsAndAccessories = TryGetEnumItem("MeshPartHeadsAndAccessories", "Default"),
		},
	},
}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return PropertyPatches

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
