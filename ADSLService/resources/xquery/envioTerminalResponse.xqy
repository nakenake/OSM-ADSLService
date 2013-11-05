declare namespace oms="urn:com:metasolv:oms:xmlapi:1";
declare namespace automator = "java:oracle.communications.ordermanagement.automation.plugin.ScriptReceiverContextInvocation";
declare namespace context = "java:com.mslv.oms.automation.TaskContext";

declare namespace saxon="http://saxon.sf.net/";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace log="java:org.apache.commons.logging.Log";

declare namespace nsrpta="http://www.optaresolutions.com/Logistica";

declare variable $automator external;
declare variable $context external;
declare variable $log external;

let $respuestaLogistica :=  /nsrpta:ResponseLogistica

let $order := fn:root(.)/oms:GetOrder.Response
let $taskDataXml := saxon:serialize($order, <xsl:output method='xml' omit-xml-declaration='yes' indent='yes' saxon:indent-spaces='4'/>)
return
(
			log:info($log, fn:concat('OSM CableService Log Message taskDataXML:[',$taskDataXml,']')),
			context:completeTaskOnExit($context,"next"),
			<UpdateOrder.Request xmlns="urn:com:metasolv:oms:xmlapi:1">
                <OrderID>{ context:getOrderId($context) }</OrderID>               
                <Update path="/ProvisionState">Ship terminal finish</Update>
            </UpdateOrder.Request>
	
)