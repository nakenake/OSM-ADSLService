declare namespace oms="urn:com:metasolv:oms:xmlapi:1";
declare namespace automator = "java:oracle.communications.ordermanagement.automation.plugin.ScriptReceiverContextInvocation";
declare namespace context = "java:com.mslv.oms.automation.TaskContext";
declare namespace correlator = "java:com.mslv.oms.automation.Correlator"; 

declare namespace saxon="http://saxon.sf.net/";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace log="java:org.apache.commons.logging.Log";


declare variable $automator external;
declare variable $context external;
declare variable $log external;

let $correlator := automator:getCorrelator($automator, $context)
let $order := fn:root(.)/oms:GetOrder.Response
let $yourCorrelationId := $order/oms:_root/oms:SalesOrderLineGroup/oms:SalesOrderLine/oms:LogisticData/oms:ShipCode/text()

let $taskDataXml := saxon:serialize($order, <xsl:output method='xml' omit-xml-declaration='yes' indent='yes' saxon:indent-spaces='4'/>)
return
(
	log:info($log, fn:concat('OSM CableService Log Message taskDataXML:[',$taskDataXml,']')),
	context:suspendTaskOnExit($context, "WaitingForShippingResponse"),
	correlator:add($correlator, $yourCorrelationId),
	log:info($log, fn:concat('OSM CableService Log Message Correlation ID:[',$yourCorrelationId,']')),
	<UpdateOrder.Request xmlns="urn:com:metasolv:oms:xmlapi:1">
                <Update path="/ProvisionState">Ship start</Update>
    </UpdateOrder.Request>
)