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

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class PhewasResult implements Comparable {

	protected String varName;
	protected String varType;
	protected String n;
	protected double beta;
	protected double lower;
	protected double upper;
	protected double pvalue;
	protected ResultType resType;
	protected String description;
	protected String isExposure;
	
	protected Integer cat1_id;
	protected String cat1_title;
	protected Integer cat2_id;
	protected String cat2_title;
	protected Integer cat3_id;
	protected String cat3_title;
	protected Integer catMultId;
	
	public PhewasResult(String [] results) {
		super();
		
		this.varName = results[0];
		this.varType = results[1];
		this.n = results[2];
		this.beta = Double.parseDouble(results[3]);

		if (results[4].length()>0)
			this.lower = Double.parseDouble(results[4]);
		if (results[5].length()>0)
			this.upper = Double.parseDouble(results[5]);

		this.pvalue = Double.parseDouble(results[6]);
		
		switch(results[7]) {
			case "LINEAR":  
				this.resType = ResultType.LINEAR;
				break;
			case "ORDERED-LOGISTIC":  
				this.resType = ResultType.ORDERED_LOGISTIC;
				break;
			case "MULTINOMIAL-LOGISTIC":  
				this.resType = ResultType.MULTINOMIAL_LOGISTIC;
				break;
			case "LOGISTIC-BINARY":  
				this.resType = ResultType.LOGISTIC_BINARY;
				break;
		}		
		
		this.description = results[8];
		this.isExposure = results[9];
		this.cat1_id = Integer.parseInt(results[10]);
		this.cat1_title = results[11];
		this.cat2_id = Integer.parseInt(results[12]);
		this.cat2_title = results[13];
		
		if (results[14]!=null && !results[14].equals("")) {
			this.cat3_id = Integer.parseInt(results[14]);
			this.cat3_title = results[15];
		}
		
		if (this.varType.equals("CAT-MUL")) {
			catMultId = Integer.parseInt(this.varName.split("#")[0]);
		}
		
	}

	
	@Override
	public String toString() {
		return cat1_id+"/"+cat2_id+"/"+cat3_id+"/"+catMultId + "/" + varName;
	}


	public int compareTo(Object o) {
		PhewasResult r = (PhewasResult)o;
		
		if (this.cat1_id < r.cat1_id)
			return 1;
		else if (this.cat1_id > r.cat1_id)
			return -1;
		else {
			
			if (this.cat2_id < r.cat2_id)
				return 1;
			else if (this.cat2_id > r.cat2_id)
				return -1;
			else {
				if (this.cat3_id < r.cat3_id)
					return 1;
				else if (this.cat3_id > r.cat3_id)
					return -1;
				else {
					// needs to be sorted by varName so cat mult results are together
					return varName.compareTo(r.varName);
					
				}
				
			}
			
		}
		
	}
	
	public List<Level> getLevels() {
		
		List<Level> levels = new ArrayList<Level>();
		
		int level=1;
		levels.add(new Level(this.cat1_title, this.cat1_id+"", "BIO-CAT", level++));
		levels.add(new Level(this.cat2_title, this.cat2_id+"", "BIO-CAT", level++));
		
		
		if (this.cat3_id!=null && !this.cat3_id.equals(this.cat2_id)) {
			levels.add(new Level(this.cat3_title, this.cat3_id+"", "BIO-CAT", level++));
		}
		
		if (this.catMultId!=null) {
			
			levels.add(new Level(this.description, this.catMultId+"", "CAT-MUL", level++));
			
			// add a stucture node for the letter because these cat mult fields have lots of categories (too many nodes on the graph showing at once!)
			if (this.catMultId==41201 || this.catMultId==41202 || this.catMultId==41204 || this.catMultId==41200 || this.catMultId==41210) {
				String catId = this.varName.split("#")[1];
				Pattern r = Pattern.compile("\\A([A-Z]+)(\\d+)");
				Matcher m = r.matcher(catId);
				if (m.find( )) {
					String startLetters = m.group(1);
					levels.add(new Level("Codes starting with: "+startLetters, this.varName.split("#")[0]+"-"+startLetters, "CAT-MUL-PART", level++));
				}
			
			}
		
		}
		
		return levels;
		
	}
	
	
	class Level {
		String name; 
		String id; 
		String type;
		int level;
		
		public Level(String name, String id, String type, int level) {
			this.name = name;
			this.id = id;
			this.type = type;
			this.level = level;
		}
	
	}


	/**
	 * Get the type of result - whether it's null, or positive, negative or unordered, and weak, or strong.
	 * @return
	 */
	public AssociationCategory getAssociationCategory() {
		
		if (pvalue > 0.05)
			return AssociationCategory.NULL;
		else if (resType == ResultType.MULTINOMIAL_LOGISTIC) {
			if (pvalue<ResultsToJSON.pThreshold) 
				return AssociationCategory.UNORDEREDSTRONG;
			else 
				return AssociationCategory.UNORDEREDWEAK;
		}
		else {
			
			if (pvalue<ResultsToJSON.pThreshold && beta>0) 
				return AssociationCategory.POSITIVESTRONG;
			else if (pvalue<ResultsToJSON.pThreshold && beta<0)
				return AssociationCategory.NEGATIVESTRONG;
			else if (beta>0) 
				return AssociationCategory.POSITIVEWEAK;
			else if (beta<0)
				return AssociationCategory.NEGATIVEWEAK;
			else {
				throw new IllegalArgumentException("Beta is zero but result is not null");
			}
		}
		
	}


	public String getDisplayName() {
		// For unordered results we also display the baseline category that was used
		// For categorical (multiple) fields we also display the category for this particular result
		String varN =  (resType.equals(ResultType.MULTINOMIAL_LOGISTIC) ? varName.replace("-", "; baseline:"): (varName.contains("#") ? varName.replace("#", "; category:"): varName));
		String displayName = description  + " (" + varN + ")";
		return displayName;
	}
	
	public String getIsExposure() {
		return isExposure;
	}


	public void setIsExposure(String isExposure) {
		this.isExposure = isExposure;
	}
	
}
