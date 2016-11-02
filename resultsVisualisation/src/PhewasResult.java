import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;

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
		this.lower = Double.parseDouble(results[4]);
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
		levels.add(new Level(this.cat1_title, this.cat1_id, "BIO-CAT", level++));
		levels.add(new Level(this.cat2_title, this.cat2_id, "BIO-CAT", level++));
		
		
		if (this.cat3_id!=null && !this.cat3_id.equals(this.cat2_id)) {
			levels.add(new Level(this.cat3_title, this.cat3_id, "BIO-CAT", level++));
		}
		
		if (this.catMultId!=null)
			levels.add(new Level(this.description, this.catMultId, "CAT-MUL", level++));
		
		return levels;
		
	}
	
	
	class Level {
		String name; 
		int id; 
		String type;
		int level;
		
		public Level(String name, int id, String type, int level) {
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
	
}
