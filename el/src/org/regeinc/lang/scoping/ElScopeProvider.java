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
import org.regeinc.lang.el.State;
import org.regeinc.lang.el.StateOrVariable;
import org.regeinc.lang.util.Finder;

/** 
 * see : http://www.eclipse.org/Xtext/documentation/latest/xtext.html#scoping
 * on how and when to use it 
 *
 */
public class ElScopeProvider extends AbstractDeclarativeScopeProvider {

	IScope scope_Instance_stateOrVariable(EObject context, EReference reference){
		List<StateOrVariable> allStateOrVariable = new ArrayList<StateOrVariable>();
		State state = null;
		if(context.eContainer() instanceof State){
			state = (State)context.eContainer();
		}
		allStateOrVariable.addAll(Finder.allState(context, state));
		allStateOrVariable.addAll(Finder.allAssociation(context, null));
		allStateOrVariable.addAll(Finder.allParameter(context));
		
		IScope iscope = Scopes.scopeFor(allStateOrVariable);
		return iscope;
	}
}
