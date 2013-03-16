package org.regeinc.lang.generator

import org.regeinc.lang.el.Instance
import org.regeinc.lang.el.NewInstance
import org.regeinc.lang.el.ListInstance
import org.regeinc.lang.el.Literal
import org.regeinc.lang.el.DECIMAL_LITERAL
import org.regeinc.lang.el.Argument
import org.regeinc.lang.el.State
import org.regeinc.lang.el.TypeRef
import org.regeinc.lang.el.StateOrVariable

class InstanceJ {
	private new(){		
	}
	static InstanceJ instanceJ
	def static InstanceJ instance(){
		if(instanceJ==null)
			instanceJ = new InstanceJ()
		return instanceJ
	}

	def compile(Instance instance)'''
		«IF instance.stateOrVariable!=null»«compile(instance.stateOrVariable)»«IF instance.referredStateOrVariable!=null»«compileReferred(instance.referredStateOrVariable)»«ENDIF»«
		ELSEIF instance.literal!=null»«compile(instance.literal)»«
		ELSEIF instance.listInstance!=null»«compile(instance.listInstance)»«
		ELSEIF instance.newInstance!=null»«compile(instance.newInstance)»«
		ELSEIF instance.dotMethodCall!=null»«MethodJ::instance.compile(instance.dotMethodCall)»«
		ELSEIF instance.operatorCall!=null»«MethodJ::instance.compile(instance.operatorCall)»«ENDIF»'''
		
	def compile(NewInstance newInstance)'''
		new «newInstance.entity.name»(«IF newInstance.argument!=null»«ENDIF»)«
			IF !newInstance.allNestedInstance.nullOrEmpty»«
				FOR nestedInstance:newInstance.allNestedInstance
					».with«nestedInstance.specificTypeRef.typeRef.name.toFirstUpper»(«compile(nestedInstance.instance)»)«
				ENDFOR»«
			ENDIF»'''

	def compile(StateOrVariable stateOrVariable)'''
		«IF stateOrVariable instanceof State»is«(stateOrVariable as State).name.toFirstUpper»()«
			ELSEIF stateOrVariable instanceof TypeRef»«(stateOrVariable as TypeRef).name»«ENDIF»'''

	def compileReferred(StateOrVariable stateOrVariable)'''
		.«IF stateOrVariable instanceof State»is«(stateOrVariable as State).name.toFirstUpper»()«
			ELSEIF stateOrVariable instanceof TypeRef»get«(stateOrVariable as TypeRef).name.toFirstUpper»()«ENDIF»'''
	
	def compile(ListInstance listInstance)'''
		java.util.Arrays.asList(«compile(listInstance.argument)»)'''	

	def compile(Argument argument)'''
		«compile(argument.instance)»«IF argument.list», «compile(argument.next)»«ENDIF»'''
	
	def compile(Literal literal)'''
		«IF literal.string!=null»«literal.string»«
		ELSEIF literal.number!=null»«compile(literal.number)»«
		ELSEIF literal.THIS!=null»this«
		ELSEIF literal.NULL!=null»null«
		ELSEIF literal.TRUE!=null»true«
		ELSEIF literal.FALSE!=null»false«ENDIF»'''

	def compile(DECIMAL_LITERAL decimal)'''
		«IF decimal.integer!=null»«decimal.integer»«ENDIF»«
			IF decimal.PERIOD».«decimal.fraction»«IF decimal.FLOATING»f«ENDIF»«ELSEIF decimal.TOOLONG»l«ENDIF»'''
	
}