declare namespace oms="urn:com:metasolv:oms:xmlapi:1";
declare namespace automator = "java:oracle.communications.ordermanagement.automation.plugin.ScriptSenderContextInvocation";
declare namespace context = "java:com.mslv.oms.automation.TaskContext";
declare namespace ocontext = "java:com.mslv.oms.automation.OrderContext";



declare namespace saxon="http://saxon.sf.net/";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace log="java:org.apache.commons.logging.Log";


declare variable $automator external;
declare variable $context external;
declare variable $log external;


let $order := fn:root(.)/oms:GetOrder.Response

let $update := <UpdateOrder.Request xmlns="urn:com:metasolv:oms:xmlapi:1">
                <OrderID>{ context:getOrderId($context) }</OrderID>
                <UpdatedNodes>
					<_root>
					<ProvisionState>Inventory Start</ProvisionState>
					</_root>
				</UpdatedNodes>
            </UpdateOrder.Request>

let $taskDataXml := saxon:serialize($order, <xsl:output method='xml' omit-xml-declaration='yes' indent='yes' saxon:indent-spaces='4'/>)
let $updateXml := saxon:serialize($update, <xsl:output method='xml' omit-xml-declaration='yes' indent='yes' saxon:indent-spaces='4'/>)

return
(
	automator:setUpdateOrder($automator,"true"), 
	log:info($log, fn:concat('OSM CableService Log Message Inventory Task Order Data:[',$taskDataXml,']')),
	let $ret := ocontext:updateOrderData($context,$updateXml)
	return 
        log:info($log, fn:concat('###### Updating COM order: ' , $ret)),
		context:suspendTaskOnExit($context, "WaitingForInventoryResponse"),
		<RequestConsultaInventario>
			<ServiceId>{$order/oms:_root/oms:SalesOrderLineGroup/oms:SalesOrderLine/oms:ServiceId/text()}</ServiceId>
			<State>{$order/oms:_root/oms:SalesOrderLineGroup/oms:Address/oms:State/text()}</State>
			<City>{$order/oms:_root/oms:SalesOrderLineGroup/oms:Address/oms:City/text()}</City>
			<Postalcode>{$order/oms:_root/oms:SalesOrderLineGroup/oms:Address/oms:PostalCode/text()}</Postalcode>
			<Product>{$order/oms:_root/oms:SalesOrderLineGroup/oms:SalesOrderLine/oms:Product/text()}</Product>
			<Speed>{$order/oms:_root/oms:SalesOrderLineGroup/oms:SalesOrderLine/oms:Speed/text()}</Speed>
			<Profile>{$order/oms:_root/oms:SalesOrderLineGroup/oms:SalesOrderLine/oms:Profile/text()}</Profile>			
		</RequestConsultaInventario>
	
)