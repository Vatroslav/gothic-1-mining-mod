// Whole Vein Mining: one dig empties the whole ore vein.
//
// The game gives a few pieces per dig (UMiningConfig). This mod replaces the
// hero's mining ability with a subclass. When a dig starts, it moves all ore but
// one piece from the vein to the hero. The game's dig then takes the last piece,
// so the vein empties the usual way.
//
// The mining ability is native, so only the standard GAS events are available:
// ActivateAbility (runs only if the native code calls its parent) and
// OnEndAbility. If the start event does not run, the rest of the vein is moved
// when the dig ends instead.

// Settings > Game > Whole Vein Mining.
UCLASS(Config=GameUserSettings)
class UWholeVeinMiningSettings : UGothicModExt_UserSettings
{
    default CategoryName = FText::FromString("Whole Vein Mining");

    UPROPERTY(Config)
    FModUserSettingsBool Enabled = FModUserSettingsBool(
        Value = true,
        DefaultValue = true,
        DisplayText = FText::FromString("One dig empties the whole vein"));
}

// Swaps the hero's mining ability for the one below.
UCLASS(meta=(ReplaceParentClass))
class UGE_Player_Definition_WholeVeinMining : UGE_Player_Definition
{
    default RemoveAbility(UGameplayAbilityMining::StaticClass());
    default AddAbility(UWholeVeinMining_Ability::StaticClass());
}

class UWholeVeinMining_Ability : UGameplayAbilityMining
{
    UPROPERTY()
    AActor Vein;

    // Ore counts when the dig started. -1 = not tracked.
    int HeroOreAtStart = -1;
    int VeinOreAtStart = -1;

    UFUNCTION(BlueprintOverride)
    void ActivateAbility()
    {
        ClearTracking();
        if (!UWholeVeinMiningSettings.DefaultObject.Enabled.bValue)
            return;

        AGothicCharacter Hero = Cast<AGothicCharacter>(GetAvatarActorFromActorInfo());
        AActor FoundVein = FindVein();
        if (!IsValid(Hero) || !IsValid(FoundVein))
            return;

        Vein = FoundVein;
        HeroOreAtStart = Hero.Inventory.CountItemsOfClass(UItMi_Orenugget::StaticClass());
        VeinOreAtStart = OreInVein(Vein);
        MoveOreToHero(Vein, Hero, VeinOreAtStart - 1);
    }

    UFUNCTION(BlueprintOverride)
    void OnEndAbility(bool bWasCancelled)
    {
        AGothicCharacter Hero = Cast<AGothicCharacter>(GetAvatarActorFromActorInfo());
        if (IsValid(Hero) && UWholeVeinMiningSettings.DefaultObject.Enabled.bValue)
        {
            if (VeinOreAtStart >= 0 && IsValid(Vein))
            {
                // The hero should end up with exactly what left the vein. If the
                // game's dig gave more than the one piece that was left, take
                // the extra back.
                int Gained = Hero.Inventory.CountItemsOfClass(UItMi_Orenugget::StaticClass()) - HeroOreAtStart;
                int Taken = VeinOreAtStart - OreInVein(Vein);
                if (Gained > Taken)
                {
                    int Removed = Hero.Inventory.RemoveItemOfClass(UItMi_Orenugget::StaticClass(), Gained - Taken);
                }
            }
            else
            {
                // Nothing was moved when the dig started, so move the rest of
                // the vein now.
                AActor LateVein = FindVein();
                if (IsValid(LateVein))
                    MoveOreToHero(LateVein, Hero, OreInVein(LateVein));
            }
        }
        ClearTracking();
    }

    void ClearTracking()
    {
        Vein = nullptr;
        HeroOreAtStart = -1;
        VeinOreAtStart = -1;
    }

    AActor FindVein()
    {
        auto IO = Cast<AInteractiveObjectActor>(m_InteractiveActor.Get());
        if (!IsValid(IO))
            return nullptr;

        auto Definition = IO.GetInteractiveObjectDefinition();
        if (!IsValid(Definition) || !Definition.IsA(UGenericMiningSpot))
            return nullptr;

        return IO;
    }

    int OreInVein(AActor Actor)
    {
        auto Container = DataModule::GetContainerDataModule(Actor);
        if (!IsValid(Container))
            return 0;

        int Count = 0;
        for (auto Slot : Container.GetItemsInConst(EInventoryTypes::MainContainer))
        {
            auto Item = Cast<UItemDefinition>(Slot.m_SlotData.m_ItemDefinition.GetDefaultObject());
            if (IsValid(Item) && Item.IsA(UItMi_Orenugget))
                Count += Math::Max(0, Slot.m_SlotData.m_ItemCount);
        }
        return Count;
    }

    void MoveOreToHero(AActor FromVein, AGothicCharacter Hero, int Amount)
    {
        if (Amount <= 0)
            return;

        auto Container = DataModule::GetContainerDataModule(FromVein);
        if (!IsValid(Container))
            return;

        // Count again after removing, so the hero gets only what really left the vein.
        int Before = OreInVein(FromVein);
        Container.ConsumeItemOfType(UItMi_Orenugget::StaticClass(), Amount);
        int Moved = Before - OreInVein(FromVein);

        if (Moved > 0)
            Hero.Inventory.AddItemOfClass(UItMi_Orenugget::StaticClass(), Moved);
    }
}
