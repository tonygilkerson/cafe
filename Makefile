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
	@echo "  $$ make getSerialGateway"
	@echo "    This will pull the latest chart for the serial-gateway"
	@echo ""
	@echo "  $$ make getISpy"
	@echo "    This will pull the latest chart for the ISpy"
	@echo ""
	@echo "  $$ make docServe  - Start mkdocs dev sandbox"
	@echo "  $$ make docPub    - Publish doc to Gighub pages"	
endef

help:
	$(call help_info)

externalCharts:
	@echo "Pull external charts"
	bin/external-charts.sh --chart-list external-charts.txt --output ${PWD}/external-charts --chart "$(chart)"

getSerialGateway:
	@echo "Get Serial Gateway"
	rm -fr .temp/serial-gateway || true
	rm -rf external-charts/serial-gateway || true
	mkdir -p .temp
	git -C .temp clone git@github.com:tonygilkerson/serial-gateway.git
	cp -r .temp/serial-gateway/charts/serial-gateway external-charts/

getISpy:
	@echo "Get ISpy"
	rm -fr .temp/ispy || true
	rm -rf external-charts/ispy || true
	mkdir -p .temp
	git -C .temp clone git@github.com:tonygilkerson/ispy.git
	cp -r .temp/ispy/charts/ispy external-charts/

getNotebook:
	@echo "Get Notebook"
	rm -fr .temp/notebook || true
	rm -rf external-charts/notebook || true
	mkdir -p .temp
	git -C .temp clone git@github.com:tonygilkerson/notebook.git
	cp -r .temp/notebook/charts/notebook external-charts/

docServe:
	source ".venv/bin/activate"; mkdocs serve


docPub:
	source ".venv/bin/activate"; git pull; mkdocs build --clean; mkdocs gh-deploy