/*
 * generated by Xtext
 */
package org.regeinc.lang.scoping;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.xtext.scoping.IScope;
import org.eclipse.xtext.scoping.Scopes;
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider;
import org.regeinc.lang.el.Comparison;
import org.regeinc.lang.el.Entity;
import org.regeinc.lang.el.Expression;
import org.regeinc.lang.el.For;
import org.regeinc.lang.el.Instance;
import org.regeinc.lang.el.MethodDeclaration;
import org.regeinc.lang.el.MethodDefinition;
import org.regeinc.lang.el.Model;
import org.regeinc.lang.el.Reference;
import org.regeinc.lang.el.Select;
import org.regeinc.lang.el.State;
import org.regeinc.lang.el.StateComparison;
import org.regeinc.lang.el.Type;
import org.regeinc.lang.util.Finder;

/** 
 * see : http://www.eclipse.org/Xtext/documentation/latest/xtext.html#scoping
 * on how and when to use it 
 *
 */
public class ElScopeProvider extends AbstractDeclarativeScopeProvider {
	
	IScope scope_StateComparison_state(EObject context, EReference eReference){
		List<State> allStates =  new ArrayList<>();
		if(context instanceof StateComparison){
			StateComparison stateComparison = (StateComparison) context;
			if(stateComparison.eContainer() instanceof Comparison){
				Comparison comparison = (Comparison)stateComparison.eContainer();				
				Expression expression = comparison.getExpression();
				if(expression.getDivision()!=null){
					if(expression.getDivision().getAddition()!=null){
						if(expression.getDivision().getAddition().getSubstraction()!=null){
							if(expression.getDivision().getAddition().getSubstraction().getInstance()!=null){
								Instance instance = expression.getDivision().getAddition().getSubstraction().getInstance();
								if(instance.getReference()!=null){
									allStates.addAll(Finder.allState(instance.getReference().getType(), null));
								}
							}
						}
					}
				}
			}
			
		}
		IScope iscope = Scopes.scopeFor(allStates);
		return iscope;
	}

	IScope scope_MethodCall_methodDeclaration(EObject context, EReference eReference){
		List<MethodDeclaration> allMethodDeclaration = new ArrayList<MethodDeclaration>();
		Instance instance = Finder.instance(context);
		if(instance !=null){			
			if(instance.getReference()!=null){
				Reference reference = instance.getReference();
				allMethodDeclaration.addAll(Finder.allMethodDeclaration(reference.getType()));
			}
		}
		IScope iscope = Scopes.scopeFor(allMethodDeclaration);
		return iscope;
	}
	
	IScope scope_MethodCall_reference(EObject context, EReference eReference){
		List<Reference> allReference = new ArrayList<Reference>();
		Instance instance = Finder.instance(context);
		if(instance !=null){
			if(instance.getReference()!=null){
				Reference reference = instance.getReference();
				Type type = reference.getType();
				allReference.addAll(Finder.allLocalVariable(type));
				allReference.addAll(Finder.allParameter(type));
				allReference.addAll(Finder.allAssociation(type, null));
			}
		}
		IScope iscope = Scopes.scopeFor(allReference);
		return iscope;
	}
	
	IScope scope_For_listReference(EObject context, EReference eReference){
		return referencesInScope(context, eReference);
	}
	
	IScope scope_Select_listReference(EObject context, EReference eReference){
		return referencesInScope(context, eReference);
	}
	
	IScope scope_Instance_reference(EObject context, EReference eReference){
		return referencesInScope(context, eReference);
	}
	
	private IScope referencesInScope(EObject context, EReference eReference){
		List<Reference> allReference = new ArrayList<Reference>();
		Entity  entity = (Entity)Finder.entity(context);	
		allReference.addAll(Finder.allAssociation(entity,null));
		EObject scopeContext = context;
		while(!(scopeContext instanceof Model)){			
			if(scopeContext instanceof MethodDefinition){
				MethodDefinition definition = Finder.methodDefinition(context);
				allReference.addAll(Finder.allParameter(definition));
				allReference.addAll(Finder.allLocalVariable(definition));
			}else if(scopeContext instanceof For){
				allReference.add(Finder.forVariable(scopeContext));
			}else if(scopeContext instanceof Select){
				allReference.add(Finder.selectVariable(scopeContext));
			}
			scopeContext = scopeContext.eContainer();
		}		
		IScope iscope = Scopes.scopeFor(allReference);
		return iscope;
	}	
}
