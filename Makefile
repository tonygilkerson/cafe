NOW := $(shell echo "`date +%Y-%m-%d`")
# KWOK_LATEST_RELEASE=$(curl "https://api.github.com/repos/kubernetes-sigs/kwok/releases/latest" | jq -r '.tag_name')
KWOK_LATEST_RELEASE := "v0.4.0"

#
# Display help
# 
define help_info
	@echo "\nUsage:\n"
	@echo ""
	@echo "  $$ make externalCharts chart=<chart-name>"
	@echo "    This will pull charts listed in the external-charts.txt file and store them under the external-charts folder."
	@echo "    If <chart-name> is specified then only that chart is upgraded, otherwise all charts listed in external-charts.txt file are upgraded."
	@echo "    IMPORTANT: Use git to review changes under external-charts folder. Make sure you don't stomp on custom changes."
	@echo ""

endef

help:
	$(call help_info)

externalCharts:
	@echo "Pull external charts"
	bin/external-charts.sh --chart-list external-charts.txt --output ${PWD}/external-charts --chart "$(chart)"

upgradeArgo:
	@echo "Pull Argo manifests"
	curl -o apps/argocd/k8s/manifests.yaml https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
