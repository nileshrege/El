package org.regeinc.lang.util;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.emf.ecore.EObject;
import org.regeinc.lang.el.Association;
import org.regeinc.lang.el.Constraint;
import org.regeinc.lang.el.Contract;
import org.regeinc.lang.el.Entity;
import org.regeinc.lang.el.LineStatement;
import org.regeinc.lang.el.LocalVariableBinding;
import org.regeinc.lang.el.MethodDeclaration;
import org.regeinc.lang.el.MethodDefinition;
import org.regeinc.lang.el.Model;
import org.regeinc.lang.el.Parameter;
import org.regeinc.lang.el.State;
import org.regeinc.lang.el.Type;
import org.regeinc.lang.el.Reference;

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

	public static List<Reference> associations(EObject context) {
		List<Reference> allTypeRef = new ArrayList<Reference>();
		Entity entity = (Entity) lookUp(context, new EntityCriteria());
		if (entity != null) {
			for (Association association : entity.getAllAssociation()) {
				allTypeRef.add(association.getQualifiedReference().getReference());
			}
		}
		return allTypeRef;
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
				allTypeRef.add(parameter.getQualifiedReference().getReference());
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
		class LocalVariableBindingFinder{
			List<Reference> find(LocalVariableBinding localVariableBinding) {
				List<Reference> allTypeRef = new ArrayList<Reference>();
				allTypeRef.add(localVariableBinding.getLocalVariableDeclaration().getQualifiedReference().getReference());
				if(localVariableBinding.isList()){
					allTypeRef.addAll(find(localVariableBinding.getNext()));
				}
				return allTypeRef;
			}
		}
		List<Reference> allTypeRef = new ArrayList<Reference>();
		LineStatement lineStatement = (LineStatement) lookUp(context, new LineStatementCriteria());
		if (lineStatement != null && lineStatement.getLocalVariableBinding()!= null) {
			allTypeRef.addAll(new LocalVariableBindingFinder().find(lineStatement.getLocalVariableBinding()));
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
}