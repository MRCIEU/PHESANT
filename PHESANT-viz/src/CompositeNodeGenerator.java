// The MIT License (MIT)
//
// Copyright (c) 2017 Louise AC Millard, MRC Integrative Epidemiology Unit, University of Bristol
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the "Software"), to deal in the Software without restriction, including without
// limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so, subject to the following
// conditions:
// 
// The above copyright notice and this permission notice shall be included in all copies or substantial portions
// of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
// TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.

import java.util.Iterator;
import java.util.List;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

public class CompositeNodeGenerator {

	/**
	 * For each node in a given level, look at the level one level down (nearer the leaves) to calculate the number of results of each time in the subtree
	 * for which this node is the root. If the child nodes are result nodes then we just add one to that particular node type. If the child node is a structure node,
	 * then we use the composite _children nodes, that have already been generated (because we work up from the leaves to the root) and add these counts to the counts of this current node.
	 * @param levelNodes - all the nodes in a given level of the JSON tree.
	 */
	public static void addCompositeChildNodes(List<JSONObject> levelNodes) {
		
		Iterator<JSONObject> iter = levelNodes.iterator();
		
		while (iter.hasNext()) {
		
			// for each node at this level, we iterate across its child nodes and count the number of each result type - null, weak or strong
			JSONObject structureNode = iter.next();
			int nullCount = 0;
			int weakCount = 0;
			int strongCount = 0;
			
			boolean onlyResultsChildren = true;
			JSONArray children = (JSONArray) structureNode.get("children");
			Iterator<JSONObject> childIter = children.iterator();
			while (childIter.hasNext()) {
				
				JSONObject child = childIter.next();
				if (child.get("structure")==null) {
					// child is a result node so determine the result type and increment this counter
					String result = (String) child.get("result");
					if (result.endsWith("WEAK"))
						weakCount++;
					else if (result.endsWith("STRONG"))
						strongCount++;
					else if (result.equals("NULL"))
						nullCount++;
				}
				else { 
					// child is a structure node so use its composite nodes to get the numbers in this subtree
					JSONArray childCompositeChildren = (JSONArray) child.get("_children");
					Iterator<JSONObject> iterx = childCompositeChildren.iterator();
					while (iterx.hasNext()) {
						
						JSONObject obj = iterx.next();
						Integer size = (Integer) obj.get("size");
						if (obj.get("result")=="NULL") {
							nullCount += size;
						}
						else if (obj.get("result")=="WEAK") {
							weakCount += size;
						} 
						else if (obj.get("result")=="STRONG") {
							strongCount += size;
						}
					}
					onlyResultsChildren = false;
				}
			}
			
			if (onlyResultsChildren==true)
				structureNode.put("end", 1);
			
			// make the composite children - null, weak and strong
			JSONArray compositeChildren = new JSONArray();
			if (nullCount>0) {
				String resultStr = nullCount==1? structureNode.get("name") + ": " + nullCount+" null result" : structureNode.get("name") + ": " + nullCount+" null results";
				JSONObject nullComposite = makeCompositeChild(structureNode.get("id") +"compositeNull",nullCount, resultStr, "NULL");
				compositeChildren.add(nullComposite);
			}
			if (weakCount>0) {
				String resultStr = weakCount==1? structureNode.get("name") + ": " + weakCount+" weak result" : structureNode.get("name") + ": " + weakCount+" weak results";
				JSONObject weakComposite = makeCompositeChild(structureNode.get("id") +"compositeWeak",weakCount, resultStr, "WEAK");
				compositeChildren.add(weakComposite);				
			}
			if (strongCount>0) {
				String resultStr = strongCount==1? structureNode.get("name") + ": " + strongCount+" strong result" : structureNode.get("name") + ": " + strongCount+" strong results";
				JSONObject strongComposite = makeCompositeChild(structureNode.get("id") +"compositeStrong",strongCount, resultStr, "STRONG");
				compositeChildren.add(strongComposite);				
			}
			structureNode.put("_children", compositeChildren);
		}
		
	}
	
	public static JSONObject makeCompositeChild(String id, int size, String name, String result) {
		JSONObject obj = new JSONObject();
		obj.put("id", id);
		obj.put("size", size);
		obj.put("name", name);
		obj.put("type", "diamond");
		obj.put("result", result);
		return obj;
	}
	
}
