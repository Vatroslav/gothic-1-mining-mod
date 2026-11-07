// Whole Vein Mining: one dig empties the whole ore vein.
//
// The game gives a few pieces per dig (UMiningConfig). This mod replaces the
// hero's mining ability with a subclass. When a dig starts, it moves all ore but
// one piece from the vein to the hero. The game's dig then takes the last piece,
// so the vein empties the usual way.

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
    void OnActivateAbility_Scriptable(FGameplayAbilityActorInfo GAActorInfo,
                                      FGameplayEventData TriggerEventData)
    {
        ClearTracking();
        if (!UWholeVeinMiningSettings.DefaultObject.Enabled.bValue)
            return;

        AGothicCharacter Hero = Cast<AGothicCharacter>(GetAvatarActorFromActorInfo());
        if (!IsValid(Hero))
            return;

        HeroOreAtStart = Hero.Inventory.CountItemsOfClass(UItMi_Orenugget::StaticClass());

        Vein = FindVein();
        if (!IsValid(Vein))
            return;

        VeinOreAtStart = OreInVein(Vein);
        MoveOreToHero(Vein, Hero, VeinOreAtStart - 1);
    }

    UFUNCTION(BlueprintOverride)
    void OnEndAbility_Scriptable(FGameplayAbilityActorInfo GameplayAbilityActorInfo, bool WasCancelled)
    {
        AGothicCharacter Hero = Cast<AGothicCharacter>(GetAvatarActorFromActorInfo());
        if (HeroOreAtStart >= 0 && IsValid(Hero))
        {
            int Gained = Hero.Inventory.CountItemsOfClass(UItMi_Orenugget::StaticClass()) - HeroOreAtStart;

            if (VeinOreAtStart >= 0 && IsValid(Vein))
            {
                // The hero should end up with exactly what left the vein. If the
                // game's dig gave more than the one piece that was left, take
                // the extra back.
                int Taken = VeinOreAtStart - OreInVein(Vein);
                if (Gained > Taken)
                {
                    int Removed = Hero.Inventory.RemoveItemOfClass(UItMi_Orenugget::StaticClass(), Gained - Taken);
                }
            }
            else if (Gained > 0)
            {
                // The vein was not known when the dig started. The dig did give
                // ore, so move the rest of the vein now.
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
