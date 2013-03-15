package org.regeinc.lang.generator

import org.regeinc.lang.el.OperatorCall
import org.regeinc.lang.el.Operator

class OperatorJ {
	def compile(OperatorCall operatorCall)'''
		«compile(operatorCall.operator)» «InstanceJ::instance.compile(operatorCall.instance)»«
		IF operatorCall.operatorCall!=null»«compile(operatorCall.operatorCall)»«ENDIF»'''
	
	def compile(Operator operator)'''
		
	'''
}