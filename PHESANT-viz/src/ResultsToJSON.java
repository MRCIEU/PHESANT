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

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

public class ResultsToJSON {

	protected String resultsFile;
	protected String nodePositionsFile;
	protected String outputFile;
	protected List<PhewasResult> phewasResults = new ArrayList<PhewasResult>();
	protected static double pThreshold;
	HashMap<String, Double> xpositions = new HashMap<String, Double>();
	HashMap<String, Double> ypositions = new HashMap<String, Double>();
	
	// these store the nodes in each category so that we can then go up the category hierarchy one level 
	// at a time to generate the composite _children nodes
	List<JSONObject> level0nodes = new ArrayList<JSONObject>();
	List<JSONObject> level1nodes = new ArrayList<JSONObject>();
	List<JSONObject> level2nodes = new ArrayList<JSONObject>();
	List<JSONObject> level3nodes = new ArrayList<JSONObject>();
	List<JSONObject> level4nodes = new ArrayList<JSONObject>();	
	List<JSONObject> level5nodes = new ArrayList<JSONObject>();	
	
	public static void main (String []args) {
		
		if (args.length!=3)
			throw new IllegalArgumentException("Three arguments required: 1) path to results files, 2) path to node position file and 3) path to output file");
		
		String resultsFile = args[0];
		String nodePositionsFile = args[1];
		String outputFile = args[2];
		ResultsToJSON r = new ResultsToJSON(resultsFile, nodePositionsFile, outputFile);
		r.doResultsToJSON();
	}
	
	public ResultsToJSON(String resultsFile, String nodePositionsFile, String outputFile) {
		super();
		this.resultsFile = resultsFile;
		this.nodePositionsFile = nodePositionsFile;
		this.outputFile = outputFile;
	}
	
	public void doResultsToJSON() {
		
        String line = "";
        String cvsSplitBy = "\t";

        readNodePositions();
        int exposureCount = 0;
        
        try (BufferedReader br = new BufferedReader(new FileReader(resultsFile))) {

        	boolean first =true;
            while ((line = br.readLine()) != null) {

            	if (first==false) {
	                String[] result = line.split(cvsSplitBy);
	                PhewasResult pr = new PhewasResult(result);
	                
	                if (pr.getIsExposure().length()==0)
	                	phewasResults.add(pr);
	                else
	                	exposureCount++;
            	} else
            		first = false;
            }
           

        } catch (IOException e) {
            e.printStackTrace();
        }
        
        System.out.println("Number of phenotypes marked as denoting exposure: " + exposureCount);
        System.out.println("Number of results (excluding those marked as denoting exposure): " + phewasResults.size());
        
        pThreshold = 0.05/phewasResults.size();
        System.out.println("Bonferroni corrected P value threshold: " + pThreshold);
        
        Collections.sort(phewasResults);
		
        // make root node
        JSONObject obj = new JSONObject();
        level0nodes.add(obj);
        obj.put("id", "ROOT");
        obj.put("name", "Root");
        obj.put("xpos", ""+xpositions.get("ROOT"));
        obj.put("ypos", ""+ypositions.get("ROOT"));
        obj.put("type", "circle");
        obj.put("catm", 0);
        obj.put("structure", 1);
        
        // children of root are the biobank root categories
        JSONArray children = new JSONArray();
        obj.put("children", children);
        
        Iterator<PhewasResult> iter = phewasResults.iterator();
        
        while (iter.hasNext()) {
        	PhewasResult r = iter.next();
        	addNode(obj, r);
        }
        
        // diamond nodes that summarise results in each subtree
        addCompositeChildNodes();
        
        // save to file
        saveToFile(obj);
        
	}
	
	private void addCompositeChildNodes() {
		CompositeNodeGenerator.addCompositeChildNodes(level5nodes);
		CompositeNodeGenerator.addCompositeChildNodes(level4nodes);
		CompositeNodeGenerator.addCompositeChildNodes(level3nodes);
		CompositeNodeGenerator.addCompositeChildNodes(level2nodes);
		CompositeNodeGenerator.addCompositeChildNodes(level1nodes);
		CompositeNodeGenerator.addCompositeChildNodes(level0nodes);
	}

	/**
	 * Prints the JSON tree to file
	 * @param root - root node of JSON tree
	 */
	private void saveToFile(JSONObject root) {
		String jsonstr = root.toJSONString();
		PrintWriter out;
		try {
			out = new PrintWriter(outputFile);
			out.write(jsonstr);
			out.flush();
			out.close();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
	}

	private void readNodePositions() {

		String line = "";
        String cvsSplitBy = ",";

        try (BufferedReader br = new BufferedReader(new FileReader(nodePositionsFile))) {

            while ((line = br.readLine()) != null) {

	                // use comma as separator
	                String[] result = line.split(cvsSplitBy);
	                
	                String varId = result[0];
	                double xpos = Double.parseDouble(result[1]);
	                double ypos = Double.parseDouble(result[2]);
	                xpositions.put(varId, xpos);
	                ypositions.put(varId, ypos);
            }
           

        } catch (IOException e) {
            e.printStackTrace();
        }
		
	}

	/**
	 * Takes a result (one row in result CSV) and adds the nodes to the JSON tree, including any category nodes or the categorical multiple root node, if they
	 * don't already exist
	 * @param root - root node of out JSON tree
	 * @param r - one result from the pheWAS
	 */
	private void addNode(JSONObject root, PhewasResult r) {
		
		JSONObject currentNode = root;
		
		List<PhewasResult.Level> levels = r.getLevels();
		Iterator<PhewasResult.Level> iter = levels.iterator();
		while (iter.hasNext()) {
			
			PhewasResult.Level l = iter.next();
			
			// find structure node if it already exists 
			JSONObject jo = findChild((JSONArray)currentNode.get("children"), l);
			if (jo==null) {
				
				// make structure node - either a biobank category or a categorical multiple field
				jo = makeStructureNode(l);
				((JSONArray)currentNode.get("children")).add(jo);
				
				if (l.level==1) // we use these lists when adding the composite nodes at the end
					level1nodes.add(jo);
				else if (l.level==2)
					level2nodes.add(jo);
				else if (l.level==3)
					level3nodes.add(jo);
				else if (l.level==4)
					level4nodes.add(jo);
				else if (l.level==5)
					level5nodes.add(jo);
				
			}
			
			// go to next level in hierarchy
			currentNode = jo;
		}
		
		// end of path so add the result node
		JSONObject resObj = makeResultNode(r);
		((JSONArray)currentNode.get("children")).add(resObj);
		
	}

	/**
	 * Makes a structure node - either a biobank category or a categorical multiple root node (internal nodes in the tree hierarchy)
	 * @param l
	 * @return The new node
	 */
	private JSONObject makeStructureNode(PhewasResult.Level l) {
		String id = l.type + l.id;
		JSONObject jo = new JSONObject();
		jo.put("id", id);
		jo.put("name", l.name + " (" + l.id + ")");
		jo.put("type", "circle");
		jo.put("structure", 1);
		jo.put("catm", l.type.equals("CAT-MUL")?1:0);
		jo.put("catmpart", l.type.equals("CAT-MUL-PART")?1:0);
		jo.put("children", new JSONArray());
//		jo.put("parent", currentNode); 
		jo.put("xpos", ""+xpositions.get(id));
		jo.put("ypos", ""+ypositions.get(id));
		return jo;
	}

	/**
	 * Makes a new JSON object for one pheWAS result (leaves in the tree hierarchy)
	 * @param r
	 * @return The created node for this result
	 */
	private JSONObject makeResultNode(PhewasResult r) {
		JSONObject resObj = new JSONObject();
		resObj.put("id", "r"+r.varName);
		resObj.put("name", r.getDisplayName());
		resObj.put("result", r.getAssociationCategory().toString());
		if (r.getAssociationCategory().equals(AssociationCategory.NEGATIVESTRONG) || r.getAssociationCategory().equals(AssociationCategory.NEGATIVEWEAK))
			resObj.put("type", "triangle-down");
		else if (r.getAssociationCategory().equals(AssociationCategory.POSITIVESTRONG) || r.getAssociationCategory().equals(AssociationCategory.POSITIVEWEAK))
			resObj.put("type", "triangle-up");
		else if (r.getAssociationCategory().equals(AssociationCategory.NULL))
			resObj.put("type", "square");
		else 
			resObj.put("type", "circle");
		return resObj;
	}

	/**
	 * Finds structure node in the given array of child nodes
	 * @param currentChildren
	 * @param l
	 * @return The structure node if it already exists, and null otherwise
	 */
	private JSONObject findChild(JSONArray currentChildren, PhewasResult.Level l) {
		
		Iterator<JSONObject> iter = currentChildren.iterator();
		while (iter.hasNext()) {
			
			JSONObject o = iter.next();
			if (o.get("id").equals(l.type + l.id))
					return o;
		}
		
		return null;
		
	}
	
}
