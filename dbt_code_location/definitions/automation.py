from dagster import AutoMaterializePolicy, AutoMaterializeRule

wait_for_all_parents_policy = AutoMaterializePolicy.eager().with_rules(
    AutoMaterializeRule.skip_on_not_all_parents_updated()
)
