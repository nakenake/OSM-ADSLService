declare namespace oms="urn:com:metasolv:oms:xmlapi:1";
declare namespace automator = "java:oracle.communications.ordermanagement.automation.plugin.ScriptReceiverContextInvocation";
declare namespace context = "java:com.mslv.oms.automation.TaskContext";
declare namespace ocontext = "java:com.mslv.oms.automation.OrderContext";

declare namespace saxon="http://saxon.sf.net/";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
declare namespace log="java:org.apache.commons.logging.Log";

declare namespace inv="http://www.optaresolutions.com/Inventory";

declare variable $automator external;
declare variable $context external;
declare variable $log external;

declare function local:getStatus(
    $taskData as element()) as xs:string
{    
    let $error := $taskData/inv:Error/text()
    let $status := 
	if (fn:empty($error))
        then
        (
           "next"
        )
        else
        (
        	"failure"
        )       
    return
        $status
};




let $respuestaLogistica :=  fn:root(.)/inv:ResponseInventory
let $errorNote := $respuestaLogistica/inv:Error/text()
let $update := <UpdateOrder.Request xmlns="urn:com:metasolv:oms:xmlapi:1">
                <OrderID>{ context:getOrderId($context) }</OrderID>                
				 <UpdatedNodes>
					<_root>
						<ProvisionState>Inventory Finish</ProvisionState>
						<SalesOrderLineGroup>							
							<SalesOrderLine>
								<InventoryData>
										{
											if (fn:empty($errorNote))
											then
											(												
												<Port>{$respuestaLogistica/inv:Port/text()}</Port>,
												<DslamName>{$respuestaLogistica/inv:Dslam/text()}</DslamName>,
												<CentralId>{$respuestaLogistica/inv:CentralId/text()}</CentralId>													
											)
											else
											(
												<ErrorNotes>{$respuestaLogistica/inv:Error/text()}</ErrorNotes>
											)											          					
										}
										</InventoryData>
							</SalesOrderLine>
						</SalesOrderLineGroup>
					</_root>
				</UpdatedNodes>
            </UpdateOrder.Request>		
let $updateXml := saxon:serialize($update, <xsl:output method='xml' omit-xml-declaration='yes' indent='yes' saxon:indent-spaces='4'/>)		
return
(			automator:setUpdateOrder($automator,"true"), 
			log:info($log, fn:concat('OSM CableService Log Message Inventory Update response:[',$updateXml,']')),
			context:completeTaskOnExit($context,local:getStatus($respuestaLogistica)),
			$update 				
)