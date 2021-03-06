package org.regeinc.lang.util;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.emf.ecore.EObject;
import org.regeinc.lang.el.Association;
import org.regeinc.lang.el.Constraint;
import org.regeinc.lang.el.Contract;
import org.regeinc.lang.el.Entity;
import org.regeinc.lang.el.Expression;
import org.regeinc.lang.el.For;
import org.regeinc.lang.el.Instance;
import org.regeinc.lang.el.LineStatement;
import org.regeinc.lang.el.MethodDeclaration;
import org.regeinc.lang.el.MethodDefinition;
import org.regeinc.lang.el.Model;
import org.regeinc.lang.el.Parameter;
import org.regeinc.lang.el.Reference;
import org.regeinc.lang.el.Select;
import org.regeinc.lang.el.State;
import org.regeinc.lang.el.Statement;
import org.regeinc.lang.el.Type;
import org.regeinc.lang.el.impl.LineStatementImpl;

interface Criteria {
	boolean isSatisfiedBy(EObject context);
}

class TypeCriteria implements Criteria{
	public boolean isSatisfiedBy(EObject context) {
		return context instanceof Type;
	}
}

class ContractCriteria implements Criteria{
	public boolean isSatisfiedBy(EObject context) {
		return context instanceof Contract;
	}
}

class EntityCriteria implements Criteria{
	public boolean isSatisfiedBy(EObject context) {
		return context instanceof Entity;
	}
}

class MethodDeclarationCriteria implements Criteria{
	public boolean isSatisfiedBy(EObject context) {
		return context instanceof MethodDeclaration;
	}
}

class MethodDefinitionCriteria implements Criteria{
	public boolean isSatisfiedBy(EObject context) {
		return context instanceof MethodDefinition;
	}
}

class ConstraintCriteria implements Criteria{
	public boolean isSatisfiedBy(EObject context) {
		return context instanceof Constraint;
	}
}

class ConditionCriteria implements Criteria{
	public boolean isSatisfiedBy(EObject context) {
		return context instanceof ConditionCriteria;
	}
}

class LineStatementCriteria implements Criteria{
	public boolean isSatisfiedBy(EObject context) {
		return context instanceof LineStatement;
	}
}

class InstanceCriteria implements Criteria{
	public boolean isSatisfiedBy(EObject context) {
		return context instanceof Instance;
	}
}

class ExpressionCriteria implements Criteria{
	public boolean isSatisfiedBy(EObject context) {
		return context instanceof Expression;
	}
}

class SelectCriteria implements Criteria{
	public boolean isSatisfiedBy(EObject context) {
		return context instanceof Select;
	}
}

class ForCriteria implements Criteria{
	public boolean isSatisfiedBy(EObject context) {
		return context instanceof For;
	}
}

public class Finder {
	
	public static EObject lookUp(EObject context, Criteria criteria) {
		if (criteria.isSatisfiedBy(context)) {
			return context;
		} else if (!(context.eContainer() instanceof Model)) {
			return lookUp(context.eContainer(), criteria);
		} else {
			return null;
		}
	}

	public static Type type(EObject context) {
		Type type = (Entity) lookUp(context, new TypeCriteria());
		return type;
	}

	public static Entity entity(EObject context) {
		return (Entity) lookUp(context, new EntityCriteria());
	}
	
	public static Instance instance(EObject context) {
		return (Instance) lookUp(context, new InstanceCriteria());
	}

	public static Expression expression(EObject context) {
		return (Expression) lookUp(context, new ExpressionCriteria());
	}

	public static MethodDeclaration methodDeclaration(EObject context) {
		Entity entity = (Entity) lookUp(context, new EntityCriteria());
		if (entity != null) {
			for (MethodDefinition methodDefinition : entity.getAllMethodDefinition()) {
				if(methodDefinition.getMethodDeclaration().equals(context))
					return methodDefinition.getMethodDeclaration();
			}
		}
		return null;
	}

	public static MethodDefinition methodDefinition(EObject context){
		return (MethodDefinition) lookUp(context, new MethodDefinitionCriteria());
	}
	
	public static List<Reference> allAssociation(EObject context, Association excluded) {
		List<Reference> allTypeRef = new ArrayList<Reference>();
		Entity entity = (Entity) lookUp(context, new EntityCriteria());
		if (entity != null) {
			for(Association association : entity.getAllAssociation()){
				if(excluded!=null){
					if(excluded.equals(association)) 
						continue;
				}
				allTypeRef.add(association.getQualifiedReference().getReference());
			}
		}
		return allTypeRef;
	}

	public static List<State> allState(EObject context, State excluded) {
		List<State> allState = new ArrayList<State>();
		Entity entity = (Entity) lookUp(context, new EntityCriteria());
		if (entity != null) {
			for(State state : entity.getAllState()){
				if(excluded!=null){
					if(state.equals(excluded))
						continue;	
				}
				allState.add(state);	
			}
		}
		return allState;
	}

	public static List<MethodDeclaration> allMethodDeclaration(EObject context) {
		List<MethodDeclaration> allMethodDeclaration = new ArrayList<MethodDeclaration>();
		Contract contract = (Contract) lookUp(context, new ContractCriteria());
		if (contract != null) {
			for (MethodDeclaration declaration : contract.getAllMethodDeclaration()) {
				allMethodDeclaration.add(declaration);
			}
		}else{
			Entity entity = (Entity) lookUp(context, new EntityCriteria());
			if (entity != null) {
				for (MethodDefinition definition : entity.getAllMethodDefinition()) {
					allMethodDeclaration.add(definition.getMethodDeclaration());
				}
			}	
		}		
		return allMethodDeclaration;
	}
	
	public static List<MethodDefinition> allMethodDefinition(EObject context) {
		List<MethodDefinition> allMethodDefinition = new ArrayList<MethodDefinition>();
		Entity entity = (Entity) lookUp(context, new EntityCriteria());
		if (entity != null) {
			for (MethodDefinition definition : entity.getAllMethodDefinition()) {
				allMethodDefinition.add(definition);
			}
		}		
		return allMethodDefinition;
	}

	public static List<Reference> allParameter(EObject context) {
		class ParameterFinder {
			List<Reference> find(Parameter parameter) {
				List<Reference> allTypeRef = new ArrayList<Reference>();
				allTypeRef.add(parameter.getReference());
				if(parameter.isList()){
					allTypeRef.addAll(find(parameter.getNext()));
				}
				return allTypeRef;
			}
		}

		List<Reference> allTypeRef = new ArrayList<Reference>();
		MethodDefinition methodDefinition = (MethodDefinition) lookUp(context, new MethodDefinitionCriteria());
		if(methodDefinition!=null){
			MethodDeclaration methodDeclaration = methodDefinition.getMethodDeclaration();
			if (methodDeclaration != null) {
				Parameter parameter = methodDeclaration.getParameter();
				allTypeRef.addAll(new ParameterFinder().find(parameter));
			}	
		}
		return allTypeRef;
	}

	public static List<Reference> allLocalVariable(EObject context) {
		List<Reference> allTypeRef = new ArrayList<Reference>();
		
		EObject eObject = lookUp(context, new MethodDefinitionCriteria());
		if(eObject!=null){
			MethodDefinition methodDefinition = (MethodDefinition) eObject;
			if(methodDefinition.getMethodBody()!=null && methodDefinition.getMethodBody().getAllStatement()!=null){
				for(Statement stmt : methodDefinition.getMethodBody().getAllStatement()){
					if(stmt.getLineStatement()!=null){
						LineStatement lineStatement = stmt.getLineStatement();
						if (lineStatement.getLocalVariableDeclaration()!= null) {
							allTypeRef.add(lineStatement.getLocalVariableDeclaration().getQualifiedReference().getReference());
						}						
					}
				}
			}
		}
		return allTypeRef;
	}
	
	public static Reference selectVariable(EObject context) {
		EObject eObject = lookUp(context, new SelectCriteria());
		if(eObject!=null){
			Select select = (Select) eObject;
			return select.getReference();
		}
		return null;
	}

	public static Reference forVariable(EObject context) {
		EObject eObject = lookUp(context, new ForCriteria());
		if(eObject!=null){
			For phore = (For) eObject;
			return phore.getReference();
		}
		return null;
	}

}